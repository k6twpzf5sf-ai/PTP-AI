// 10x primitive: cal-ai/design-tokens v1
import SwiftUI

/// Central design tokens for the clinical cal-ai language. The app's whole
/// theme lives here: retheme by editing these values, add new tokens here,
/// and never hardcode colors or fonts in views.
///
/// Values are the observed palette from REFERENCE.md: strictly monochrome
/// structure (near-black ink doubling as the accent, white cards on a warm
/// off-white ground) plus a muted three-color data trio and small green/red
/// semantic accents. Type is the standard system grotesque with monospaced
/// digits — numbers do the shouting.
@available(iOS 17.0, *)
public enum ClinicalTokens {
    // MARK: Pantry-to-Plate warm-paper theme
    public static let ground = Color(red: 0.969, green: 0.953, blue: 0.918)
    public static let surface = Color.white
    public static let surfaceRaised = Color.white
    public static let hairline = Color(red: 0.855, green: 0.831, blue: 0.780)

    public static let ink = Color(red: 0.173, green: 0.165, blue: 0.145)
    public static let inkSecondary = Color(red: 0.404, green: 0.388, blue: 0.345)
    public static let inkOnAccent = Color.white

    public static let accent = Color(red: 0.420, green: 0.478, blue: 0.227)
    public static let accentSoft = Color(red: 0.420, green: 0.478, blue: 0.227).opacity(0.14)
    public static let positive = Color(red: 0.282, green: 0.510, blue: 0.286)
    public static let negative = Color(red: 0.655, green: 0.271, blue: 0.204)
    public static let warning = Color(red: 0.620, green: 0.420, blue: 0.165)

    public static let dataRose = Color(red: 0.694, green: 0.377, blue: 0.300)
    public static let dataAmber = Color(red: 0.620, green: 0.420, blue: 0.165)
    public static let dataAzure = Color(red: 0.345, green: 0.459, blue: 0.510)

    // MARK: Radii
    /// Working card radius (log cards, plan cards, option rows).
    public static let radiusCard: CGFloat = 16
    /// Inner elements: thumbnails, small containers.
    public static let radiusControl: CGFloat = 12
    /// Large sheet / tile radius (sheet tops, stat tiles use `radiusTile`).
    public static let radiusSheet: CGFloat = 28
    /// Stat tiles and section cards.
    public static let radiusTile: CGFloat = 20

    // MARK: Type
    /// Hero numerals — bold system grotesque with tabular digits.
    public static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold).monospacedDigit()
    }
    public static let titleFont: Font = .system(.title, weight: .bold)
    public static let headlineFont: Font = .system(.headline, weight: .semibold)
    public static let bodyFont: Font = .system(.body)
    public static let captionFont: Font = .system(.footnote)
}

#Preview("Token swatches") {
    if #available(iOS 17.0, *) {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("cal-ai tokens").font(ClinicalTokens.titleFont)
                ForEach(
                    [("ground", ClinicalTokens.ground), ("surface", ClinicalTokens.surface),
                     ("hairline", ClinicalTokens.hairline), ("ink", ClinicalTokens.ink),
                     ("inkSecondary", ClinicalTokens.inkSecondary), ("accent", ClinicalTokens.accent),
                     ("positive", ClinicalTokens.positive), ("negative", ClinicalTokens.negative),
                     ("warning", ClinicalTokens.warning), ("dataRose", ClinicalTokens.dataRose),
                     ("dataAmber", ClinicalTokens.dataAmber), ("dataAzure", ClinicalTokens.dataAzure)],
                    id: \.0
                ) { name, color in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                            .frame(width: 44, height: 28)
                            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(ClinicalTokens.hairline))
                        Text(name).font(ClinicalTokens.bodyFont).foregroundStyle(ClinicalTokens.ink)
                    }
                }
                Text("1,850").font(ClinicalTokens.display(44)).foregroundStyle(ClinicalTokens.ink)
                Text("Numbers do the shouting")
                    .font(ClinicalTokens.captionFont)
                    .foregroundStyle(ClinicalTokens.inkSecondary)
            }
            .padding(20)
        }
        .background(ClinicalTokens.ground)
    }
}
