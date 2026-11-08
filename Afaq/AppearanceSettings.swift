import Observation
import SwiftUI

enum SceneMood: String, CaseIterable, Identifiable {
    case sunset, midnight, dawn
    var id: String { rawValue }
    var title: String {
        switch self {
        case .sunset: "الغروب"
        case .midnight: "الليل"
        case .dawn: "الفجر"
        }
    }
    var symbol: String {
        switch self {
        case .sunset: "sunset"
        case .midnight: "moon.stars"
        case .dawn: "sunrise"
        }
    }
}

@MainActor @Observable
final class AppearanceSettings {
    @ObservationIgnored private let defaults: UserDefaults

    var mood: SceneMood { didSet { defaults.set(mood.rawValue, forKey: "appearance.mood") } }
    var arabicDigits: Bool { didSet { defaults.set(arabicDigits, forKey: "appearance.arabicDigits") } }
    var use24HourClock: Bool { didSet { defaults.set(use24HourClock, forKey: "appearance.24Hour") } }
    var showSeconds: Bool { didSet { defaults.set(showSeconds, forKey: "appearance.seconds") } }
    var showSunrise: Bool { didSet { defaults.set(showSunrise, forKey: "appearance.sunrise") } }
    var backgroundDimming: Double { didSet { defaults.set(backgroundDimming, forKey: "appearance.dimming") } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        mood = SceneMood(rawValue: defaults.string(forKey: "appearance.mood") ?? "") ?? .sunset
        arabicDigits = defaults.object(forKey: "appearance.arabicDigits") as? Bool ?? true
        use24HourClock = defaults.object(forKey: "appearance.24Hour") as? Bool ?? false
        showSeconds = defaults.object(forKey: "appearance.seconds") as? Bool ?? true
        showSunrise = defaults.object(forKey: "appearance.sunrise") as? Bool ?? true
        backgroundDimming = min(max(defaults.object(forKey: "appearance.dimming") as? Double ?? 0.15, 0), 0.65)
    }

    func reset() {
        mood = .sunset
        arabicDigits = true
        use24HourClock = false
        showSeconds = true
        showSunrise = true
        backgroundDimming = 0.15
    }

    func digits(_ value: String) -> String {
        guard arabicDigits else { return value }
        let arabic = Array("٠١٢٣٤٥٦٧٨٩")
        return String(value.map { character in
            guard let number = character.wholeNumberValue, (0...9).contains(number) else { return character }
            return arabic[number]
        })
    }

    func time(hour: Int, minute: Int) -> String {
        if use24HourClock {
            return digits(String(format: "%02d:%02d", hour, minute))
        }
        let suffix = hour >= 12 ? "م" : "ص"
        return digits(String(format: "%d:%02d", hour % 12 == 0 ? 12 : hour % 12, minute)) + " " + suffix
    }
}
