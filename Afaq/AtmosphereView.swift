import SwiftUI
import UIKit

struct AtmosphereView: View {
    @Environment(AppearanceSettings.self) private var settings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var refreshID = UUID()
    var extendsIntoSafeArea = true

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let scene = DaylightScene.resolve(mood: settings.mood, date: context.date)
            GeometryReader { geometry in
                ZStack {
                    Color.black
                    landscape(scene: scene, size: geometry.size)
                        .id(settings.mood)
                        .transition(.opacity)
                    celestialBodies(scene: scene, size: geometry.size)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 2), value: scene)

                    LinearGradient(
                        stops: [.init(color: .black.opacity(0.18), location: 0),
                                .init(color: .clear, location: 0.4),
                                .init(color: .black.opacity(0.15), location: 0.62),
                                .init(color: .black.opacity(0.72), location: 1)],
                        startPoint: .top, endPoint: .bottom
                    )
                    Color.black.opacity(settings.backgroundDimming)
                }
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.8), value: settings.mood)
                .clipped()
                .environment(\.layoutDirection, .leftToRight)
            }
        }
        .id(refreshID)
        .ignoresSafeArea(.container, edges: extendsIntoSafeArea ? .all : [])
        .accessibilityHidden(true)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refreshID = UUID() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            refreshID = UUID()
        }
    }

    private func landscape(scene: DaylightScene, size: CGSize) -> some View {
        ZStack {
            photograph(scene.firstAsset, size: size)
            if scene.firstAsset != scene.secondAsset {
                photograph(scene.secondAsset, size: size).opacity(scene.blend)
            }
        }
        .mask {
            LinearGradient(
                stops: [.init(color: .white, location: 0),
                        .init(color: .white, location: 0.65),
                        .init(color: .clear, location: 0.8)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    private func photograph(_ asset: String, size: CGSize) -> some View {
        // Anchor the same horizon above the rows, including in wide settings previews.
        let scale = max(size.width / 851, size.height / 1848)
        let width = 851 * scale
        let height = 1848 * scale
        return Image(asset)
            .resizable()
            .frame(width: width, height: height)
            .offset(x: (size.width - width) / 2, y: size.height * 0.44 - height * 0.655)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
            .clipped()
    }

    private func celestialBodies(scene: DaylightScene, size: CGSize) -> some View {
        let sunSize = max(8, size.width * 0.03)
        let moonSize = max(12, size.width * 0.046)
        let warmth = scene.sunWarmth
        return ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(red: 1, green: 0.98 - warmth * 0.12, blue: 0.82 - warmth * 0.30),
                             Color(red: 1, green: 0.88 - warmth * 0.27, blue: 0.58 - warmth * 0.43)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: sunSize, height: sunSize)
                .shadow(color: .orange.opacity(0.45), radius: 12 + warmth * 10)
                .position(
                    x: size.width * (0.17 + scene.sunProgress * 0.66),
                    y: size.height * (0.44 - sin(scene.sunProgress * .pi) * 0.085)
                )
                .opacity(scene.sunOpacity)

            Circle()
                .fill(LinearGradient(colors: [.white, Color(red: 0.66, green: 0.78, blue: 0.92)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay {
                    Circle().fill(.black)
                        .offset(x: moonSize * 0.32, y: -moonSize * 0.12)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .frame(width: moonSize, height: moonSize)
                .clipped()
                .shadow(color: .white.opacity(0.22), radius: 9)
                .position(
                    x: size.width * (0.20 + scene.moonProgress * 0.60),
                    y: size.height * (0.44 - sin(scene.moonProgress * .pi) * 0.04)
                )
                .opacity(scene.moonOpacity)
        }
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
