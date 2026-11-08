import SwiftUI

private enum AppTab: Hashable { case today, settings }

struct AppRootView: View {
    @State private var tab = AppTab.today

    var body: some View {
        TabView(selection: $tab) {
            HomeView { tab = .settings }
                .tabItem { Label("اليوم", systemImage: "sun.horizon") }
                .tag(AppTab.today)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("الإعدادات", systemImage: "gearshape") }
            .tag(AppTab.settings)
        }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("--preview-settings") {
                tab = .settings
            }
        }
    }
}

#Preview("أفق — الرئيسية") {
    AppRootView()
        .environment(AppearanceSettings(defaults: UserDefaults(suiteName: "Afaq.Preview")!))
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}
