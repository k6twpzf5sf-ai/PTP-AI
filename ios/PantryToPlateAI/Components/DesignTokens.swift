import Foundation
import SwiftUI

enum AppTokens {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let huge: CGFloat = 48
        static let screenMargin: CGFloat = 20
    }

    static let background = ClinicalTokens.ground
    static let surface = ClinicalTokens.surface
    static let ink = ClinicalTokens.ink
    static let secondaryInk = ClinicalTokens.inkSecondary
    static let accent = ClinicalTokens.accent
    static let onAccent = ClinicalTokens.inkOnAccent
    static let positive = ClinicalTokens.positive
    static let warning = ClinicalTokens.warning
    static let hairline = ClinicalTokens.hairline
    static let cardRadius = ClinicalTokens.radiusCard
    static let controlRadius = ClinicalTokens.radiusControl
    static let tileRadius = ClinicalTokens.radiusTile

    static let displayFont = Font.system(.largeTitle, design: .serif).weight(.bold)
    static let titleFont = Font.system(.title2, design: .serif).weight(.bold)
    static let headlineFont = Font.system(.headline).weight(.semibold)
    static let bodyFont = Font.system(.body)
    static let captionFont = Font.system(.footnote)
}

struct PrimaryCTAStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTokens.headlineFont)
            .foregroundStyle(AppTokens.onAccent)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(AppTokens.accent.opacity(configuration.isPressed ? 0.82 : 1), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}
