import SwiftUI

struct HomeView: View {
    @Environment(AppearanceSettings.self) private var settings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPrayerID = "maghrib"
    @State private var presentedPrayer: PreviewPrayer?
    @Namespace private var prayerGlassNamespace
    @ScaledMetric(relativeTo: .largeTitle) private var prayerNameSize = 58
    @ScaledMetric(relativeTo: .largeTitle) private var countdownSize = 62
    @ScaledMetric(relativeTo: .body) private var rowTextSize = 17
    let openSettings: () -> Void

    private var prayers: [PreviewPrayer] {
        PreviewPrayer.day.filter { settings.showSunrise || $0.id != "sunrise" }
    }

    var body: some View {
        GeometryReader { geometry in
            let metrics = HomeLayoutMetrics(height: max(1, geometry.size.height - 16), prayerCount: prayers.count)
            VStack(spacing: 0) {
                hero(height: metrics.heroHeight)
                    .frame(height: metrics.heroHeight)
                Spacer(minLength: 0)
                schedule(metrics: metrics)
                Text("معاينة التصميم · مواقيت توضيحية")
                    .font(AfaqFont.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.white.opacity(0.65))
                    .frame(height: 30, alignment: .bottom)
            }
            .frame(maxWidth: 600, maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .frame(width: geometry.size.width, height: geometry.size.height)
            // Extend only the backdrop under system chrome; keep content in the safe area.
            .background { AtmosphereView() }
            .foregroundStyle(.white)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DateLocationHeader()
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
        .sheet(item: $presentedPrayer) { prayer in
            PrayerDetailView(prayer: prayer)
                .presentationDetents([.height(390), .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
        }
    }

    private func hero(height: CGFloat) -> some View {
        VStack(spacing: min(6, height * 0.02)) {
            Text("الصلاة القادمة")
                .font(AfaqFont.hero(size: min(15, height * 0.07)))
                .lineLimit(1)
                .foregroundStyle(.white.opacity(0.75))
            Text("المغرب")
                .font(AfaqFont.hero(size: min(prayerNameSize * settings.textScale, height * 0.22), weight: .medium))
                .minimumScaleFactor(0.65)
                .lineLimit(1)
            ViewThatFits(in: .horizontal) {
                countdown(size: min(countdownSize * settings.textScale, height * 0.24))
                countdown(size: min(countdownSize * settings.textScale, height * 0.24) * 0.74)
            }
            .accessibilityLabel(settings.showSeconds ? "عد تنازلي توضيحي: 24 دقيقة و18 ثانية" : "عد تنازلي توضيحي: 24 دقيقة")
            Text("حتى الأذان · " + settings.time(hour: 17, minute: 12))
                .font(AfaqFont.hero(size: min(15, height * 0.07)))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
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

    @ViewBuilder private func schedule(metrics: HomeLayoutMetrics) -> some View {
        if #available(iOS 26.0, *) {
            // Keep independent capsules separated while sharing one glass rendering container.
            GlassEffectContainer(spacing: 4) {
                prayerRows(metrics: metrics)
            }
        } else {
            prayerRows(metrics: metrics)
        }
    }

    private func prayerRows(metrics: HomeLayoutMetrics) -> some View {
        VStack(spacing: metrics.rowSpacing) {
            ForEach(prayers) { prayer in
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.82)) {
                        selectedPrayerID = prayer.id
                    }
                    presentedPrayer = prayer
                } label: {
                    PrayerRow(
                        prayer: prayer,
                        isSelected: selectedPrayerID == prayer.id,
                        height: metrics.rowHeight,
                        fontSize: min(rowTextSize * settings.textScale, metrics.rowHeight * 0.5)
                    )
                        .modifier(PrayerGlassSurface(
                            style: settings.prayerGlassStyle,
                            isSelected: selectedPrayerID == prayer.id,
                            prayerID: prayer.id,
                            namespace: prayerGlassNamespace
                        ))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedPrayerID == prayer.id ? .isSelected : [])
                .accessibilityHint("عرض تفاصيل " + prayer.name)
            }
        }
    }
}

struct PrayerRow: View {
    @Environment(AppearanceSettings.self) private var settings
    let prayer: PreviewPrayer
    let isSelected: Bool
    let height: CGFloat
    let fontSize: CGFloat

    var body: some View {
        HStack(spacing: 12) {
            PrayerIconView(prayer: prayer)
            Text(prayer.name)
                .font(AfaqFont.hero(size: fontSize, weight: prayer.isNext ? .semibold : .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 12)
            Text(settings.time(hour: prayer.hour, minute: prayer.minute))
                .font(AfaqFont.hero(size: fontSize))
                .monospacedDigit()
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .contentShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityValue(prayer.isNext ? "الصلاة القادمة" : "")
    }
}

private struct HomeLayoutMetrics {
    let rowHeight: CGFloat
    let rowSpacing: CGFloat
    let heroHeight: CGFloat

    init(height: CGFloat, prayerCount: Int) {
        rowHeight = min(52, max(44, height * 0.074))
        rowSpacing = min(10, max(6, height * 0.012))
        let scheduleHeight = CGFloat(prayerCount) * rowHeight + CGFloat(max(0, prayerCount - 1)) * rowSpacing
        // Reserve room for all prayers and the footer before sizing the hero.
        heroHeight = min(260, max(100, (height - scheduleHeight - 30) * 0.88))
    }
}

struct PrayerGlassSurface: ViewModifier {
    @Environment(AppearanceSettings.self) private var settings
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
                        (settings.glassDensity == .light ? Glass.clear : Glass.regular)
                            .tint(.white.opacity(isSelected ? 0.14 : 0.025)).interactive(),
                        in: .capsule
                    )
                    .glassEffectID(style == .selection ? "selected-prayer" : prayerID, in: namespace)
            } else {
                content
                    .background(settings.glassDensity == .light ? Material.ultraThin : Material.regular, in: Capsule())
                    .overlay {
                        Capsule().strokeBorder(.white.opacity(isSelected ? 0.3 : 0.12), lineWidth: 0.5)
                    }
            }
        } else {
            content
        }
    }
}
