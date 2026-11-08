import SwiftUI

@main
struct AfaqApp: App {
    @State private var settings = AppearanceSettings()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(settings)
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar_SA"))
                .preferredColorScheme(.dark)
                .tint(.white)
        }
    }
}
