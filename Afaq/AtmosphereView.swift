import SwiftUI

struct AtmosphereView: View {
    @Environment(AppearanceSettings.self) private var settings

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.035, green: 0.055, blue: 0.11)
                Image("DesertSunset")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                switch settings.mood {
                case .sunset:
                    Color.clear
                case .midnight:
                    Color(red: 0.04, green: 0.09, blue: 0.25)
                        .opacity(0.7)
                        .blendMode(.multiply)
                    Color.black.opacity(0.3)
                case .dawn:
                    LinearGradient(colors: [.indigo.opacity(0.45), .pink.opacity(0.23), .clear], startPoint: .top, endPoint: .bottom)
                        .blendMode(.screen)
                }

                LinearGradient(
                    stops: [.init(color: .black.opacity(0.08), location: 0),
                            .init(color: .clear, location: 0.4),
                            .init(color: .black.opacity(0.15), location: 0.62),
                            .init(color: .black.opacity(0.72), location: 1)],
                    startPoint: .top, endPoint: .bottom
                )
                Color.black.opacity(settings.backgroundDimming)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct GlassControl: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @ViewBuilder func body(content: Content) -> some View {
        if reduceTransparency {
            content.background(Color(red: 0.16, green: 0.18, blue: 0.24), in: Circle())
        } else if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: .circle)
        } else {
            content.background(.regularMaterial, in: Circle())
        }
    }
}
