import SwiftUI

struct HomeView: View {
    @Environment(AppearanceSettings.self) private var settings
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPrayerID = "maghrib"
    @Namespace private var prayerGlassNamespace
    @ScaledMetric(relativeTo: .largeTitle) private var prayerNameSize = 58
    @ScaledMetric(relativeTo: .largeTitle) private var countdownSize = 62
    let openSettings: () -> Void

    private var prayers: [PreviewPrayer] {
        PreviewPrayer.day.filter { settings.showSunrise || $0.id != "sunrise" }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                    VStack(spacing: 0) {
                        hero
                            .padding(.top, 28)
                        // Keep the horizon visible, while allowing accessibility sizes to scroll.
                        Color.clear.frame(height: typeSize.isAccessibilitySize ? 32 : max(32, geometry.size.height * 0.14))
                        schedule
                        Text("معاينة التصميم · مواقيت توضيحية")
                            .font(AfaqFont.caption2)
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
            // Extend only the backdrop under system chrome; keep content in the safe area.
            .background { AtmosphereView() }
            .foregroundStyle(.white)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Label("الرياض", systemImage: "mappin.and.ellipse")
                    .font(AfaqFont.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .accessibilityLabel("مدينة العرض التجريبي: الرياض")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("فتح الإعدادات", systemImage: "gearshape", action: openSettings)
                    .labelStyle(.iconOnly)
            }
        }
        .onChange(of: settings.showSunrise) { _, isVisible in
            if !isVisible && selectedPrayerID == "sunrise" {
                selectedPrayerID = "maghrib"
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 13) {
            Text("الصلاة القادمة")
                .font(AfaqFont.subheadline)
                .foregroundStyle(.white.opacity(0.75))
            Text("المغرب")
                .font(AfaqFont.hero(size: prayerNameSize, weight: .medium))
                .minimumScaleFactor(0.65)
                .lineLimit(1)
            ViewThatFits(in: .horizontal) {
                countdown(size: countdownSize)
                countdown(size: countdownSize * 0.74)
            }
            .accessibilityLabel(settings.showSeconds ? "عد تنازلي توضيحي: 24 دقيقة و18 ثانية" : "عد تنازلي توضيحي: 24 دقيقة")
            Text("حتى الأذان · " + settings.time(hour: 17, minute: 12))
                .font(AfaqFont.subheadline)
                .foregroundStyle(.white.opacity(0.76))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func countdown(size: CGFloat) -> some View {
        Text(settings.digits(settings.showSeconds ? "00:24:18" : "00:24"))
            .font(AfaqFont.hero(size: size))
            .monospacedDigit()
            .environment(\.layoutDirection, .leftToRight)
            .lineLimit(1)
    }

    @ViewBuilder private var schedule: some View {
        if #available(iOS 26.0, *) {
            // Keep independent capsules separated while sharing one glass rendering container.
            GlassEffectContainer(spacing: 6) {
                prayerRows
            }
        } else {
            prayerRows
        }
    }

    private var prayerRows: some View {
        VStack(spacing: 10) {
            ForEach(prayers) { prayer in
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.82)) {
                        selectedPrayerID = prayer.id
                    }
                } label: {
                    PrayerRow(prayer: prayer, isSelected: selectedPrayerID == prayer.id)
                        .modifier(PrayerGlassSurface(
                            style: settings.prayerGlassStyle,
                            isSelected: selectedPrayerID == prayer.id,
                            prayerID: prayer.id,
                            namespace: prayerGlassNamespace
                        ))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedPrayerID == prayer.id ? .isSelected : [])
                .accessibilityHint("تحديد " + prayer.name)
            }
        }
    }
}

private struct PrayerRow: View {
    @Environment(AppearanceSettings.self) private var settings
    let prayer: PreviewPrayer
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: prayer.symbol)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(isSelected || prayer.isNext ? 0.95 : 0.68))
                .frame(width: 22)
                .accessibilityHidden(true)
            Text(prayer.name)
                .font(AfaqFont.body.weight(prayer.isNext ? .semibold : .regular))
            Spacer(minLength: 12)
            Text(settings.time(hour: prayer.hour, minute: prayer.minute))
                .font(AfaqFont.body)
                .monospacedDigit()
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 52)
        .contentShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityValue(prayer.isNext ? "الصلاة القادمة" : "")
    }
}

private struct PrayerGlassSurface: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let style: PrayerGlassStyle
    let isSelected: Bool
    let prayerID: String
    let namespace: Namespace.ID

    @ViewBuilder func body(content: Content) -> some View {
        if style == .individual || isSelected {
            if reduceTransparency {
                content.background(
                    Color(white: isSelected ? 0.26 : 0.17), in: Capsule()
                )
            } else if #available(iOS 26.0, *) {
                content
                    .glassEffect(
                        .regular.tint(.white.opacity(isSelected ? 0.14 : 0.025)).interactive(),
                        in: .capsule
                    )
                    .glassEffectID(style == .selection ? "selected-prayer" : prayerID, in: namespace)
            } else {
                content
                    .background(.regularMaterial, in: Capsule())
                    .overlay {
                        Capsule().strokeBorder(.white.opacity(isSelected ? 0.3 : 0.12), lineWidth: 0.5)
                    }
            }
        } else {
            content
        }
    }
}
