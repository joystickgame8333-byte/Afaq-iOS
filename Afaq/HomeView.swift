import SwiftUI

struct HomeView: View {
    @Environment(AppearanceSettings.self) private var settings
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .largeTitle) private var prayerNameSize = 58
    @ScaledMetric(relativeTo: .largeTitle) private var countdownSize = 62
    let openSettings: () -> Void

    private var prayers: [PreviewPrayer] {
        PreviewPrayer.day.filter { settings.showSunrise || $0.id != "sunrise" }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AtmosphereView()
                ScrollView {
                    VStack(spacing: 0) {
                        header
                        hero
                            .padding(.top, 45)
                        // Keep the horizon visible, while allowing accessibility sizes to scroll.
                        Color.clear.frame(height: typeSize.isAccessibilitySize ? 32 : max(32, geometry.size.height * 0.14))
                        schedule
                        Text("معاينة التصميم · مواقيت توضيحية")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.65))
                            .padding(.top, 18)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
            .foregroundStyle(.white)
        }
    }

    private var header: some View {
        HStack {
            Label("الرياض", systemImage: "mappin.and.ellipse")
                .font(.subheadline.weight(.medium))
                .accessibilityLabel("مدينة العرض التجريبي: الرياض")
            Spacer()
            Button(action: openSettings) {
                Image(systemName: "gearshape")
                    .font(.body)
                    .frame(width: 44, height: 44)
                    .modifier(GlassControl())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("فتح الإعدادات")
        }
    }

    private var hero: some View {
        VStack(spacing: 13) {
            Text("الصلاة القادمة")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
            Text("المغرب")
                .font(.system(size: prayerNameSize, weight: .medium, design: .default))
                .minimumScaleFactor(0.65)
                .lineLimit(1)
            ViewThatFits(in: .horizontal) {
                countdown(size: countdownSize)
                countdown(size: countdownSize * 0.74)
            }
            .accessibilityLabel(settings.showSeconds ? "عد تنازلي توضيحي: ٢٤ دقيقة و١٨ ثانية" : "عد تنازلي توضيحي: ٢٤ دقيقة")
            Text("حتى الأذان · " + settings.time(hour: 17, minute: 12))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.76))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func countdown(size: CGFloat) -> some View {
        Text(settings.digits(settings.showSeconds ? "00:24:18" : "00:24"))
            .font(.system(size: size, weight: .light, design: .rounded))
            .monospacedDigit()
            .environment(\.layoutDirection, .leftToRight)
            .lineLimit(1)
    }

    private var schedule: some View {
        VStack(spacing: 2) {
            ForEach(prayers) { prayer in
                PrayerRow(prayer: prayer)
                if prayer.id != prayers.last?.id {
                    Rectangle()
                        .fill(.white.opacity(0.13))
                        .frame(height: 0.5)
                        .padding(.horizontal, 14)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

private struct PrayerRow: View {
    @Environment(AppearanceSettings.self) private var settings
    let prayer: PreviewPrayer

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: prayer.symbol)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(prayer.isNext ? 0.95 : 0.58))
                .frame(width: 22)
                .accessibilityHidden(true)
            Text(prayer.name)
                .font(.body.weight(prayer.isNext ? .semibold : .regular))
            Spacer(minLength: 12)
            Text(settings.time(hour: prayer.hour, minute: prayer.minute))
                .font(.system(.body, design: .rounded))
                .monospacedDigit()
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 47)
        .background {
            if prayer.isNext {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.13))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(.white.opacity(0.22), lineWidth: 0.5)
                    }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(prayer.isNext ? "الصلاة القادمة" : "")
    }
}
