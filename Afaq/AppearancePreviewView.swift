import SwiftUI

struct AppearancePreviewView: View {
    @Environment(AppearanceSettings.self) private var settings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPrayerID = "maghrib"
    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("المغرب")
                    .font(AfaqFont.hero(size: 25 * settings.textScale, weight: .medium))
                Spacer(minLength: 10)
                Text(settings.digits(settings.showSeconds ? "00:24:18" : "00:24"))
                    .font(AfaqFont.hero(size: 25 * settings.textScale))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .environment(\.layoutDirection, .leftToRight)
            }
            Spacer(minLength: 10)
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 4) { rows }
            } else {
                rows
            }
        }
        .padding(16)
        .frame(height: 230)
        .foregroundStyle(.white)
        .background { AtmosphereView(extendsIntoSafeArea: false) }
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .accessibilityLabel("معاينة مباشرة للمظهر")
    }

    private var rows: some View {
        VStack(spacing: 8) {
            ForEach(PreviewPrayer.day.filter { $0.id == "asr" || $0.id == "maghrib" }) { prayer in
                Button {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                        selectedPrayerID = prayer.id
                    }
                } label: {
                    PrayerRow(prayer: prayer, isSelected: selectedPrayerID == prayer.id, height: 44, fontSize: 16 * settings.textScale)
                        .modifier(PrayerGlassSurface(style: settings.prayerGlassStyle, isSelected: selectedPrayerID == prayer.id, prayerID: prayer.id, namespace: namespace))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedPrayerID == prayer.id ? .isSelected : [])
            }
        }
    }
}
