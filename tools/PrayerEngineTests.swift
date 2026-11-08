import Foundation

@main
struct PrayerEngineTests {
    static func main() throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
        let payload = try PrayerCalendarPayload.decode(data)
        let calendar = PrayerCalendarEngine.calendar
        func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
        }
        func day(_ date: Date, _ offset: Int = 120) -> [ScheduledPrayer] {
            PrayerCalendarEngine.schedule(on: date, cityOffsetSeconds: offset, payload: payload)
        }
        func time(_ prayer: ScheduledPrayer) -> String { String(format: "%02d:%02d", prayer.hour, prayer.minute) }
        func snapshot(_ now: Date) -> PrayerSnapshot {
            PrayerCalendarEngine.snapshot(now: now, today: day(now), tomorrow: day(calendar.date(byAdding: .day, value: 1, to: now)!))
        }
        // Independently verified reference-app screenshot checkpoints from Salati.
        assert(day(date(2026, 7, 20)).map(time) == ["04:13", "05:46", "12:47", "16:27", "19:52", "21:21"])
        assert(day(date(2026, 7, 21)).map(time) == ["04:14", "05:47", "12:47", "16:27", "19:51", "21:20"])
        assert(time(day(date(2026, 1, 14))[3]) == "14:39")
        assert(time(day(date(2026, 12, 31))[1]) == "06:37")
        // After Isha the entire visible schedule becomes tomorrow, including year rollover.
        let exactIsha = date(2026, 7, 20, 21, 21)
        assert(!snapshot(exactIsha.addingTimeInterval(-1)).isTomorrow)
        assert(snapshot(exactIsha).isTomorrow)
        assert(snapshot(exactIsha).next?.key == .fajr)
        assert(snapshot(exactIsha).rows.map(time) == day(date(2026, 7, 21)).map(time))
        let yearEnd = snapshot(date(2026, 12, 31, 23, 59))
        assert(calendar.component(.year, from: yearEnd.next!.date) == 2027)
        let midnight = snapshot(date(2026, 7, 21, 0, 0))
        assert(!midnight.isTomorrow && midnight.next?.key == .fajr)
        // Sunrise is a displayed event, never the next obligatory prayer.
        let fajr = day(date(2026, 7, 21))[0]
        assert(snapshot(fajr.date).next?.key == .dhuhr)
        assert(PrayerCalendarEngine.countdown(until: exactIsha, now: date(2026, 7, 20, 20, 42).addingTimeInterval(10.25), seconds: true) == "00:38:50")
        assert(PrayerCalendarEngine.countdown(until: exactIsha, now: exactIsha.addingTimeInterval(-1), seconds: false) == "00:01")
        assert(PrayerCalendarEngine.countdown(until: exactIsha, now: exactIsha.addingTimeInterval(2), seconds: true) == "00:00:00")
        // Every date and city offset, including leap day and real system DST boundaries.
        let start = date(2024, 1, 1)
        for index in 0..<366 {
            let current = calendar.date(byAdding: .day, value: index, to: start)!
            let components = calendar.dateComponents([.month, .day], from: current)
            let source = payload.days[String(format: "%02d-%02d", components.month!, components.day!)]!
            let dst = calendar.timeZone.daylightSavingTimeOffset(for: current) == 0 ? 0 : 60
            for city in PrayerCities.cities {
                let events = day(current, city.offsetSeconds)
                assert(events.count == 6)
                for event in events {
                    let parts = source[event.key.rawValue]!.split(separator: ":").map { Int($0)! }
                    let expected = parts[0] * 60 + parts[1] + Int((Double(city.offsetSeconds) / 60).rounded()) + dst
                    assert(event.hour * 60 + event.minute == expected)
                    assert(calendar.component(.hour, from: event.date) == event.hour)
                }
                assert(zip(events, events.dropFirst()).allSatisfy { $0.date < $1.date })
            }
        }
        assert(PrayerCities.nearest(latitude: 31.24864, longitude: 34.86007).id == "tel-sheva")
        assert(PrayerCities.city(id: "jerusalem")?.offsetSeconds == 0)
        // Reject missing dates, malformed times, reversed prayer order and incompatible sources.
        let original = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        func rejected(_ value: [String: Any]) -> Bool {
            let data = try! JSONSerialization.data(withJSONObject: value)
            return (try? PrayerCalendarPayload.decode(data)) == nil
        }
        var invalid = original
        invalid["baseTimeStandard"] = "summer"
        assert(rejected(invalid))
        var days = original["days"] as! [String: [String: String]]
        days.removeValue(forKey: "02-29")
        invalid = original; invalid["days"] = days
        assert(rejected(invalid))
        days = original["days"] as! [String: [String: String]]
        days["01-01"]!["fajr"] = "99:99"
        invalid = original; invalid["days"] = days
        assert(rejected(invalid))
        days["01-01"]!["fajr"] = "23:59"
        invalid["days"] = days
        assert(rejected(invalid))
        print("PASS: reference times; 366 days × \(PrayerCities.cities.count) cities; DST; leap day; next prayer; Isha/midnight/year rollover; countdown; invalid payload rejection.")
    }
}
