import Foundation
import Observation

@MainActor @Observable
final class PrayerScheduleStore {
    private(set) var city: PrayerCity
    private(set) var automatic: Bool
    private(set) var payload: PrayerCalendarPayload?
    private(set) var refreshMessage = ""
    private(set) var refreshing = false
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var cacheID = ""
    @ObservationIgnored private var today: [ScheduledPrayer] = []
    @ObservationIgnored private var tomorrow: [ScheduledPrayer] = []
    static let remoteURL = URL(string: "https://raw.githubusercontent.com/joystickgame8333-byte/TelShevaAzan-iOS01/main/TelShevaAzan/Resources/PrayerCalendar/prayer-calendar-v1.json")!

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        city = PrayerCities.city(id: defaults.string(forKey: "prayers.city") ?? "") ?? PrayerCities.defaultCity
        automatic = defaults.bool(forKey: "prayers.automatic")
        let url = Bundle.main.url(forResource: "prayer-calendar-v1", withExtension: "json", subdirectory: "PrayerCalendar")
            ?? Bundle.main.url(forResource: "prayer-calendar-v1", withExtension: "json")
        let bundled = url.flatMap { try? Data(contentsOf: $0) }.flatMap { try? PrayerCalendarPayload.decode($0) }
        let cached = defaults.data(forKey: "prayers.calendar").flatMap { try? PrayerCalendarPayload.decode($0) }
        if let cached, cached.revision >= (bundled?.revision ?? 0) { payload = cached } else { payload = bundled }
    }

    func select(_ city: PrayerCity, automatic: Bool = false) {
        self.city = city
        self.automatic = automatic
        defaults.set(city.id, forKey: "prayers.city")
        defaults.set(automatic, forKey: "prayers.automatic")
    }

    func enableAutomatic() {
        automatic = true
        defaults.set(true, forKey: "prayers.automatic")
    }

    func snapshot(at now: Date) -> PrayerSnapshot {
        guard let payload else { return PrayerSnapshot(rows: [], next: nil, isTomorrow: false) }
        let calendar = PrayerCalendarEngine.calendar
        let day = calendar.startOfDay(for: now)
        let id = "\(day.timeIntervalSince1970)-\(city.id)-\(payload.revision)"
        if id != cacheID {
            today = PrayerCalendarEngine.schedule(on: day, cityOffsetSeconds: city.offsetSeconds, payload: payload)
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day)!
            tomorrow = PrayerCalendarEngine.schedule(on: nextDay, cityOffsetSeconds: city.offsetSeconds, payload: payload)
            cacheID = id
        }
        return PrayerCalendarEngine.snapshot(now: now, today: today, tomorrow: tomorrow)
    }

    func refresh(force: Bool = false) async {
        guard !refreshing else { return }
        let last = defaults.object(forKey: "prayers.lastRefresh") as? Date ?? .distantPast
        guard force || Date().timeIntervalSince(last) >= 86400 else { return }
        refreshing = true
        defer { refreshing = false }
        do {
            var request = URLRequest(url: Self.remoteURL)
            request.timeoutInterval = 15
            request.cachePolicy = .reloadIgnoringLocalCacheData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw URLError(.badServerResponse) }
            let newPayload = try PrayerCalendarPayload.decode(data)
            if newPayload.revision > (payload?.revision ?? 0) {
                defaults.set(data, forKey: "prayers.calendar")
                payload = newPayload
            }
            defaults.set(Date(), forKey: "prayers.lastRefresh")
            refreshMessage = "التقويم محدّث"
        } catch {
            refreshMessage = payload == nil ? "تعذر تحميل التقويم. أعد المحاولة." : "تعذر التحديث؛ المواقيت المحفوظة متاحة دون إنترنت."
        }
    }
}
