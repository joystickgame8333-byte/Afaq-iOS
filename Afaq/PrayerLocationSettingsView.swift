import SwiftUI

struct PrayerLocationSettingsView: View {
    @Environment(PrayerScheduleStore.self) private var schedule
    @Environment(PrayerLocationService.self) private var location
    @Environment(\.openURL) private var openURL
    @State private var search = ""

    var body: some View {
        List {
            Section {
                LabeledContent("المدينة الحالية", value: schedule.city.name)
                LabeledContent("طريقة الاختيار", value: schedule.automatic ? "أقرب مدينة بالموقع" : "يدوي")
                Button {
                    location.request()
                } label: {
                    Label(location.resolving ? "جارٍ تحديد الموقع…" : "استخدام موقعي", systemImage: "location")
                }
                .disabled(location.resolving)
                if !location.message.isEmpty {
                    Text(location.message).font(AfaqFont.footnote).foregroundStyle(.secondary)
                }
                if location.permissionDenied {
                    Button("فتح إعدادات الآيفون") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                }
            } footer: {
                Text("المواقيت حسب تقويم تطبيق صلاتي للمدن المدعومة. الموقع يختار أقرب مدينة ولا يُرسل إلى خادم. الافتراضي تل السبع حتى تختار مدينتك.")
            }
            ForEach(PrayerRegion.allCases) { region in
                let cities = PrayerCities.cities.filter { $0.region == region && (search.isEmpty || $0.name.localizedStandardContains(search)) }
                if !cities.isEmpty {
                    Section(region.title) {
                        ForEach(cities) { city in
                            Button {
                                location.select(city)
                            } label: {
                                HStack {
                                    Text(city.name).foregroundStyle(.primary)
                                    Spacer()
                                    if city.id == schedule.city.id { Image(systemName: "checkmark").foregroundStyle(.orange) }
                                }
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $search, prompt: "ابحث عن مدينة")
        .navigationTitle("المدينة والموقع")
        .navigationBarTitleDisplayMode(.inline)
    }
}
