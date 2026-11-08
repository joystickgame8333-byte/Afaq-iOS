import Foundation

// Fixed presentation fixtures. No date, location, prayer calculation or live countdown.
struct PreviewPrayer: Identifiable {
    let id: String
    let name: String
    let hour: Int
    let minute: Int
    let symbol: String
    var isNext: Bool { id == "maghrib" }

    static let day: [PreviewPrayer] = [
        .init(id: "fajr", name: "الفجر", hour: 4, minute: 45, symbol: "sun.horizon"),
        .init(id: "sunrise", name: "الشروق", hour: 6, minute: 4, symbol: "sunrise"),
        .init(id: "dhuhr", name: "الظهر", hour: 11, minute: 37, symbol: "sun.max"),
        .init(id: "asr", name: "العصر", hour: 15, minute: 15, symbol: "sun.haze"),
        .init(id: "maghrib", name: "المغرب", hour: 17, minute: 12, symbol: "sunset"),
        .init(id: "isha", name: "العشاء", hour: 18, minute: 42, symbol: "moon")
    ]
}
