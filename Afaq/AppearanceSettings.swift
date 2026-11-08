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

enum PrayerGlassStyle: String, CaseIterable, Identifiable {
    case individual, selection
    var id: String { rawValue }
    var title: String {
        switch self {
        case .individual: "كل الصلوات"
        case .selection: "الصلاة المحددة"
        }
    }
}

enum GlassDensity: String, CaseIterable, Identifiable {
    case light, dense
    var id: String { rawValue }
    var title: String { self == .light ? "خفيف" : "كثيف" }
}

@MainActor @Observable
final class AppearanceSettings {
    @ObservationIgnored private let defaults: UserDefaults

    var mood: SceneMood { didSet { defaults.set(mood.rawValue, forKey: "appearance.mood") } }
    var prayerGlassStyle: PrayerGlassStyle {
        didSet { defaults.set(prayerGlassStyle.rawValue, forKey: "appearance.prayerGlassStyle") }
    }
    var glassDensity: GlassDensity {
        didSet { defaults.set(glassDensity.rawValue, forKey: "appearance.glassDensity") }
    }
    var textScale: Double {
        didSet { defaults.set(textScale, forKey: "appearance.textScale") }
    }
    var arabicDigits: Bool { didSet { defaults.set(arabicDigits, forKey: "appearance.arabicDigits") } }
    var use24HourClock: Bool { didSet { defaults.set(use24HourClock, forKey: "appearance.24Hour") } }
    var showSeconds: Bool { didSet { defaults.set(showSeconds, forKey: "appearance.seconds") } }
    var showSunrise: Bool { didSet { defaults.set(showSunrise, forKey: "appearance.sunrise") } }
    var backgroundDimming: Double { didSet { defaults.set(backgroundDimming, forKey: "appearance.dimming") } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let hasLatinDigitsDefault = defaults.bool(forKey: "appearance.latinDigitsDefaultV1")
        mood = SceneMood(rawValue: defaults.string(forKey: "appearance.mood") ?? "") ?? .sunset
        prayerGlassStyle = PrayerGlassStyle(rawValue: defaults.string(forKey: "appearance.prayerGlassStyle") ?? "") ?? .individual
        glassDensity = GlassDensity(rawValue: defaults.string(forKey: "appearance.glassDensity") ?? "") ?? .dense
        textScale = min(1.2, max(0.85, defaults.object(forKey: "appearance.textScale") as? Double ?? 1))
        arabicDigits = hasLatinDigitsDefault
            ? (defaults.object(forKey: "appearance.arabicDigits") as? Bool ?? false)
            : false
        use24HourClock = defaults.object(forKey: "appearance.24Hour") as? Bool ?? false
        showSeconds = defaults.object(forKey: "appearance.seconds") as? Bool ?? true
        showSunrise = defaults.object(forKey: "appearance.sunrise") as? Bool ?? true
        backgroundDimming = min(max(defaults.object(forKey: "appearance.dimming") as? Double ?? 0.15, 0), 0.65)
        // Apply the requested 1234 style once for both existing and new installations.
        // Subsequent user choices remain persistent.
        if !hasLatinDigitsDefault {
            defaults.set(false, forKey: "appearance.arabicDigits")
            defaults.set(true, forKey: "appearance.latinDigitsDefaultV1")
        }
    }

    func reset() {
        mood = .sunset
        prayerGlassStyle = .individual
        glassDensity = .dense
        textScale = 1
        arabicDigits = false
        use24HourClock = false
        showSeconds = true
        showSunrise = true
        backgroundDimming = 0.15
    }

    func digits(_ value: String) -> String {
        let arabic = Array("٠١٢٣٤٥٦٧٨٩")
        return String(value.map { character in
            guard let number = character.wholeNumberValue, (0...9).contains(number) else { return character }
            return arabicDigits ? arabic[number] : Character(String(number))
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
