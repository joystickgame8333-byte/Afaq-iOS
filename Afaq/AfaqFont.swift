import CoreText
import SwiftUI
import UIKit

enum AfaqFont {
    private static let name = "ElMessiri-Regular"

    static let body = Font.custom(name, size: 17, relativeTo: .body)
    static let subheadline = Font.custom(name, size: 15, relativeTo: .subheadline)
    static let footnote = Font.custom(name, size: 13, relativeTo: .footnote)
    static let caption2 = Font.custom(name, size: 11, relativeTo: .caption2)
    static let title = Font.custom(name, size: 28, relativeTo: .title)
    static let title2 = Font.custom(name, size: 22, relativeTo: .title2)
    static let title3 = Font.custom(name, size: 20, relativeTo: .title3)
    static let largeTitle = Font.custom(name, size: 34, relativeTo: .largeTitle)

    // Hero sizes are already scaled by @ScaledMetric in HomeView.
    static func hero(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(name, fixedSize: size).weight(weight)
    }

    @MainActor static func register() {
        guard let url = Bundle.main.url(forResource: "ElMessiri-Variable", withExtension: "ttf") else {
            assertionFailure("Bundled El Messiri font is missing")
            return
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)

        // Customize system-owned text without replacing native glass materials.
        if let title = UIFont(name: name, size: 17),
           let largeTitle = UIFont(name: name, size: 34),
           let tab = UIFont(name: name, size: 11) {
            UINavigationBar.appearance().titleTextAttributes = [
                .font: UIFontMetrics(forTextStyle: .headline).scaledFont(for: title)
            ]
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: largeTitle)
            ]
            UITabBarItem.appearance().setTitleTextAttributes([.font: tab], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([.font: tab], for: .selected)
        }
    }
}
