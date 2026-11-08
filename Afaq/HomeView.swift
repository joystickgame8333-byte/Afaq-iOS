import SwiftUI

struct HomeView: View {
    @Environment(AppearanceSettings.self) private var settings
    @Environment(PrayerScheduleStore.self) private var liveSchedule
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPrayerID = "maghrib"
    @Namespace private var prayerGlassNamespace
    @ScaledMetric(relativeTo: .largeTitle) private var prayerNameSize = 58
    @ScaledMetric(relativeTo: .largeTitle) private var countdownSize = 62
    @ScaledMetric(relativeTo: .body) private var rowTextSize = 17

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
        let snapshot = liveSchedule.snapshot(at: context.date)
        let prayers = snapshot.rows.map { item in
            PreviewPrayer(id: item.key.rawValue, name: item.key.title, hour: item.hour, minute: item.minute, symbol: "", isNext: item.key == snapshot.next?.key)
        }.filter { settings.showSunrise || $0.id != "sunrise" }
        GeometryReader { geometry in
            let metrics = HomeLayoutMetrics(height: max(1, geometry.size.height - 16), prayerCount: prayers.count)
            VStack(spacing: 0) {
                hero(height: metrics.heroHeight, snapshot: snapshot, now: context.date)
                    .frame(height: metrics.heroHeight)
                Spacer(minLength: 0)
                schedule(metrics: metrics, prayers: prayers)
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
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: settings.showSunrise) { _, isVisible in
            if !isVisible && selectedPrayerID == "sunrise" {
                selectedPrayerID = "maghrib"
            }
        }
    }

    private func hero(height: CGFloat, snapshot: PrayerSnapshot, now: Date) -> some View {
        VStack(spacing: min(6, height * 0.02)) {
            Text(snapshot.isTomorrow ? "الصلاة القادمة · غدًا" : "الصلاة القادمة")
                .font(AfaqFont.hero(size: min(15, height * 0.07)))
                .lineLimit(1)
                .foregroundStyle(.white.opacity(0.75))
            Text(snapshot.next?.key.title ?? "المواقيت غير متاحة")
                .font(AfaqFont.hero(size: min(prayerNameSize * settings.textScale, height * 0.22), weight: .medium))
                .minimumScaleFactor(0.65)
                .lineLimit(1)
            ViewThatFits(in: .horizontal) {
                countdown(size: min(countdownSize * settings.textScale, height * 0.24), next: snapshot.next, now: now)
                countdown(size: min(countdownSize * settings.textScale, height * 0.24) * 0.74, next: snapshot.next, now: now)
            }
            .accessibilityLabel("المتبقي حتى الصلاة")
            Text(snapshot.next.map { "حتى الأذان · " + settings.time(hour: $0.hour, minute: $0.minute) } ?? "تحقق من التقويم في الإعدادات")
                .font(AfaqFont.hero(size: min(15, height * 0.07)))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(.white.opacity(0.76))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func countdown(size: CGFloat, next: ScheduledPrayer?, now: Date) -> some View {
        Text(settings.digits(next.map { PrayerCalendarEngine.countdown(until: $0.date, now: now, seconds: settings.showSeconds) } ?? "--:--"))
            .font(AfaqFont.hero(size: size))
            .monospacedDigit()
            .environment(\.layoutDirection, .leftToRight)
            .lineLimit(1)
    }

    @ViewBuilder private func schedule(metrics: HomeLayoutMetrics, prayers: [PreviewPrayer]) -> some View {
        if #available(iOS 26.0, *) {
            // Keep independent capsules separated while sharing one glass rendering container.
            GlassEffectContainer(spacing: 4) {
                prayerRows(metrics: metrics, prayers: prayers)
            }
        } else {
            prayerRows(metrics: metrics, prayers: prayers)
        }
    }

    private func prayerRows(metrics: HomeLayoutMetrics, prayers: [PreviewPrayer]) -> some View {
        VStack(spacing: metrics.rowSpacing) {
            ForEach(prayers) { prayer in
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.82)) {
                        selectedPrayerID = prayer.id
                    }
                } label: {
                    PrayerRow(
                        prayer: prayer,
                        isSelected: selectedPrayerID == prayer.id,
                        height: metrics.rowHeight,
                        fontSize: min(rowTextSize * settings.textScale, metrics.rowHeight * 0.5),
                        namespace: prayerGlassNamespace
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedPrayerID == prayer.id ? .isSelected : [])
                .accessibilityHint("تحديد " + prayer.name)
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
    let namespace: Namespace.ID

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
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .frame(minWidth: 90)
                .modifier(PrayerGlassSurface(
                    style: settings.prayerGlassStyle,
                    isSelected: isSelected,
                    prayerID: prayer.id,
                    namespace: namespace
                ))
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .contentShape(Rectangle())
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
        // Keep all prayers on screen before sizing the hero.
        heroHeight = min(260, max(100, (height - scheduleHeight) * 0.88))
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
