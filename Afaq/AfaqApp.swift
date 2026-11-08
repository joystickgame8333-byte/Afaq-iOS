import SwiftUI

@main
struct AfaqApp: App {
    @State private var settings = AppearanceSettings()

    init() {
        AfaqFont.register()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(settings)
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar_SA"))
                .font(AfaqFont.body)
                .preferredColorScheme(.dark)
                .tint(.white)
        }
    }
}
