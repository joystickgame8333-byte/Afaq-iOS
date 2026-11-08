import SwiftUI

struct DateLocationHeader: View {
    @Environment(AppearanceSettings.self) private var settings

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            VStack(alignment: .leading, spacing: 1) {
                Label("الرياض", systemImage: "mappin.and.ellipse")
                    .labelStyle(.titleAndIcon)
                    .font(AfaqFont.subheadline.weight(.medium))
                Text(date(context.date, calendar: .islamicUmmAlQura) + " هـ · " + date(context.date, calendar: .gregorian) + " م")
                    .font(AfaqFont.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: 245, alignment: .leading)
            .accessibilityElement(children: .combine)
        }
    }

    private func date(_ date: Date, calendar identifier: Calendar.Identifier) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA@numbers=latn")
        var calendar = Calendar(identifier: identifier)
        calendar.timeZone = .autoupdatingCurrent
        formatter.calendar = calendar
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "d MMM"
        return settings.digits(formatter.string(from: date))
    }
}
