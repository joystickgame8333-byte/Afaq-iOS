import SwiftUI

private enum AppTab: Hashable { case today, settings }

struct AppRootView: View {
    @State private var tab = AppTab.today

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                HomeView()
            }
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
    let _ = AfaqFont.register()
    AppRootView()
        .environment(PrayerScheduleStore())
        .environment(PrayerLocationService(schedule: PrayerScheduleStore()))
        .environment(AppearanceSettings(defaults: UserDefaults(suiteName: "Afaq.Preview")!))
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
        .font(AfaqFont.body)
}
