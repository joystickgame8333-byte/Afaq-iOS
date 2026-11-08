import Foundation

enum PrayerKey: String, CaseIterable, Codable, Sendable {
    case fajr, sunrise, dhuhr, asr, maghrib, isha

    var title: String {
        switch self {
        case .fajr: "الفجر"
        case .sunrise: "الشروق"
        case .dhuhr: "الظهر"
        case .asr: "العصر"
        case .maghrib: "المغرب"
        case .isha: "العشاء"
        }
    }
}

struct PrayerCalendarPayload: Codable, Sendable {
    let schemaVersion: Int
    let revision: Int
    let sourceName: String
    let sourceURL: String
    let baseLocation: String
    let baseTimeStandard: String
    let cityOffsetsMinutes: [String: Int]
    let days: [String: [String: String]]

    static func decode(_ data: Data) throws -> Self {
        let payload = try JSONDecoder().decode(Self.self, from: data)
        let lengths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        let keys = Set(lengths.enumerated().flatMap { month, length in
            (1...length).map { String(format: "%02d-%02d", month + 1, $0) }
        })
        guard payload.schemaVersion == 1, payload.revision > 0,
              payload.baseLocation == "jerusalem", payload.baseTimeStandard == "winter",
              payload.cityOffsetsMinutes["telSheva"] == 2,
              Set(payload.days.keys) == keys,
              payload.days.values.allSatisfy({ day in
                  let minutes = PrayerKey.allCases.compactMap { key -> Int? in
                      guard let time = day[key.rawValue], time.utf8.count == 5,
                            time.utf8.allSatisfy({ (48...57).contains($0) || $0 == 58 }) else { return nil }
                      let parts = time.split(separator: ":").compactMap { Int($0) }
                      guard parts.count == 2, (0..<24).contains(parts[0]), (0..<60).contains(parts[1]) else { return nil }
                      return parts[0] * 60 + parts[1]
                  }
                  return minutes.count == 6 && zip(minutes, minutes.dropFirst()).allSatisfy { $0 < $1 }
              }) else { throw CocoaError(.fileReadCorruptFile) }
        return payload
    }
}

struct ScheduledPrayer: Sendable {
    let key: PrayerKey
    let date: Date
    let hour: Int
    let minute: Int
}

struct PrayerSnapshot {
    let rows: [ScheduledPrayer]
    let next: ScheduledPrayer?
    let isTomorrow: Bool
}

// Uses Salati's perpetual Jerusalem winter calendar, city offset rounding,
// Asia/Jerusalem daylight saving and switch to tomorrow at Isha.
enum PrayerCalendarEngine {
    static var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(identifier: "Asia/Jerusalem")!
        return value
    }

    static func schedule(on day: Date, cityOffsetSeconds: Int, payload: PrayerCalendarPayload) -> [ScheduledPrayer] {
        let calendar = calendar
        let parts = calendar.dateComponents([.year, .month, .day], from: day)
        let key = String(format: "%02d-%02d", parts.month!, parts.day!)
        guard let source = payload.days[key] else { return [] }
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day)!
        let dst = calendar.timeZone.daylightSavingTimeOffset(for: noon) == 0 ? 0 : 60
        let offset = Int((Double(cityOffsetSeconds) / 60).rounded()) + dst
        return PrayerKey.allCases.compactMap { key in
            guard let time = source[key.rawValue] else { return nil }
            let values = time.split(separator: ":").compactMap { Int($0) }
            guard values.count == 2 else { return nil }
            let total = ((values[0] * 60 + values[1] + offset) % 1440 + 1440) % 1440
            var components = parts
            components.hour = total / 60
            components.minute = total % 60
            components.second = 0
            guard let date = calendar.date(from: components) else { return nil }
            return ScheduledPrayer(key: key, date: date, hour: total / 60, minute: total % 60)
        }
    }

    static func snapshot(now: Date, today: [ScheduledPrayer], tomorrow: [ScheduledPrayer]) -> PrayerSnapshot {
        let next = (today + tomorrow).first { $0.key != .sunrise && $0.date > now }
        let showTomorrow = today.last.map { now >= $0.date } ?? false
        return PrayerSnapshot(rows: showTomorrow ? tomorrow : today, next: next, isTomorrow: showTomorrow)
    }

    static func countdown(until date: Date, now: Date, seconds: Bool) -> String {
        let remaining = max(0, Int(date.timeIntervalSince(now).rounded(.up)))
        if seconds { return String(format: "%02d:%02d:%02d", remaining / 3600, remaining / 60 % 60, remaining % 60) }
        let minutes = Int(ceil(Double(remaining) / 60))
        return String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }
}
