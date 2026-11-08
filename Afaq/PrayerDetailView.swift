import SwiftUI

struct PrayerDetailView: View {
    @Environment(AppearanceSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let prayer: PreviewPrayer

    var body: some View {
        content
            .padding(.horizontal, 26)
            .padding(.top, 22)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.white)
            .background { surface }
    }

    private var content: some View {
        VStack(spacing: 12) {
            HStack {
                Label("الرياض", systemImage: "mappin.and.ellipse")
                    .font(AfaqFont.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("إغلاق", systemImage: "xmark") { dismiss() }
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
                    .buttonStyle(.plain)
            }
            PrayerIconView(prayer: prayer, size: 56)
            Text(prayer.name)
                .font(AfaqFont.title.weight(.medium))
            Text(settings.time(hour: prayer.hour, minute: prayer.minute))
                .font(AfaqFont.largeTitle)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if prayer.isNext {
                Text("الصلاة القادمة").font(AfaqFont.subheadline)
            } else if prayer.id == "sunrise" {
                Text("وقت الشروق").font(AfaqFont.subheadline)
            }
            Spacer(minLength: 0)
            Text("موعد توضيحي لمعاينة التصميم")
                .font(AfaqFont.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var surface: some View {
        if reduceTransparency {
            RoundedRectangle(cornerRadius: 30).fill(Color(white: 0.14))
        } else if #available(iOS 26.0, *) {
            Color.clear.glassEffect(
                settings.glassDensity == .light ? .clear : .regular,
                in: .rect(cornerRadius: 30)
            )
        } else {
            RoundedRectangle(cornerRadius: 30)
                .fill(settings.glassDensity == .light ? Material.ultraThin : Material.regular)
        }
    }
}
