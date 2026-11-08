import SwiftUI

// The approved source artwork is sampled directly, rather than redrawing the icons.
struct PrayerIconView: View {
    let prayer: PreviewPrayer
    var size: CGFloat = 36

    private let sourceSize = CGSize(width: 1752, height: 897)

    private var sourceRect: CGRect {
        let centerX: CGFloat
        switch prayer.id {
        case "isha": centerX = 174
        case "maghrib": centerX = 420
        case "asr": centerX = 667
        case "dhuhr": centerX = 905
        case "sunrise": centerX = 1149
        default: centerX = 1394 // fajr
        }
        return CGRect(x: centerX - 105, y: 625, width: 210, height: 200)
    }

    var body: some View {
        let rect = sourceRect
        let scale = size / max(rect.width, rect.height)
        GeometryReader { _ in
            Image("PrayerGlassReference")
                .renderingMode(.original)
                .resizable()
                .interpolation(.high)
                .frame(width: sourceSize.width * scale, height: sourceSize.height * scale)
                .offset(
                    x: -rect.minX * scale + (size - rect.width * scale) / 2,
                    y: -rect.minY * scale + (size - rect.height * scale) / 2
                )
        }
        .frame(width: size, height: size)
        .clipped()
        .colorEffect(ShaderLibrary.isolateApprovedGlassIcon())
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityHidden(true)
    }
}
