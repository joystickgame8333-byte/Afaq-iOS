import SwiftUI

@main
struct AfaqApp: App {
    @State private var settings = AppearanceSettings()
    @State private var schedule: PrayerScheduleStore
    @State private var location: PrayerLocationService
    @Environment(\.scenePhase) private var scenePhase

    init() {
        AfaqFont.register()
        let schedule = PrayerScheduleStore()
        _schedule = State(initialValue: schedule)
        _location = State(initialValue: PrayerLocationService(schedule: schedule))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(settings)
                .environment(schedule)
                .environment(location)
                .task {
                    if schedule.automatic { location.request() }
                    await schedule.refresh()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        if schedule.automatic { location.request() }
                        Task { await schedule.refresh() }
                    }
                }
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar_SA"))
                .font(AfaqFont.body)
                .preferredColorScheme(.dark)
                .tint(.white)
        }
    }
}
