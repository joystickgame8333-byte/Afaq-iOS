import Foundation
import CoreGraphics

// A visual clock-driven cycle, intentionally independent from prayer and solar calculations.
struct DaylightScene: Equatable {
    let firstAsset: String
    let secondAsset: String
    let blend: Double
    let sunProgress: Double
    let moonProgress: Double
    let sunOpacity: Double
    let moonOpacity: Double
    let sunWarmth: Double

    static func resolve(mood: SceneMood, date: Date, calendar: Calendar = .autoupdatingCurrent) -> Self {
        let minute: Double
        switch mood {
        case .automatic:
            let clock = calendar.dateComponents([.hour, .minute], from: date)
            minute = Double((clock.hour ?? 0) * 60 + (clock.minute ?? 0))
        case .dawn: minute = 310
        case .sunrise: minute = 390
        case .day: minute = 720
        case .afternoon: minute = 960
        case .sunset: minute = 1090
        case .midnight: minute = 0
        }

        let keyframes: [(minute: Double, asset: String)] = [
            (0, "AtmosphereNight"), (240, "AtmosphereNight"),
            (330, "AtmosphereDawn"), (420, "AtmosphereDawn"),
            (540, "AtmosphereDay"), (840, "AtmosphereDay"),
            (1050, "AtmosphereSunset"), (1080, "AtmosphereSunset"),
            (1170, "AtmosphereNight"), (1440, "AtmosphereNight")
        ]
        let index = keyframes.indices.dropLast().first {
            minute >= keyframes[$0].minute && minute < keyframes[$0 + 1].minute
        } ?? 0
        let first = keyframes[index]
        let second = keyframes[index + 1]
        let amount = smooth((minute - first.minute) / (second.minute - first.minute))
        let solarProgress = clamp((minute - 360) / 750)
        // Start the lunar arc at its fade-in boundary, so it never jumps while visible.
        let nightMinutes = minute >= 1125 ? minute - 1125 : minute + 315
        let sunOpacity = smooth((minute - 345) / 30) * (1 - smooth((minute - 1095) / 30))
        let moonOpacity = (1 - smooth((minute - 300) / 60)) + smooth((minute - 1125) / 45)

        return Self(
            firstAsset: first.asset,
            secondAsset: second.asset,
            blend: amount,
            sunProgress: solarProgress,
            moonProgress: clamp(nightMinutes / 675),
            sunOpacity: sunOpacity,
            moonOpacity: clamp(moonOpacity),
            sunWarmth: abs(solarProgress * 2 - 1)
        )
    }

    private static func clamp(_ value: Double) -> Double { min(1, max(0, value)) }
    private static func smooth(_ value: Double) -> Double {
        let value = clamp(value)
        return value * value * (3 - 2 * value)
    }
}
