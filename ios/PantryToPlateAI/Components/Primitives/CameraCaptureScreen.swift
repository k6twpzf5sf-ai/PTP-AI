// 10x primitive: cal-ai/camera-capture-screen v1
//
// Camera overlay chrome only — no camera code. Sits above a host-supplied
// camera preview: darkened surround with a cutout, corner brackets, and one
// of two overlay modes. `.viewfinder`: near-square cutout, sweeping scan
// line, mode chips, gallery chip, and shutter. `.barcode` (absorbed from the
// former barcode overlay): wide short reticle, hint capsule, torch chip, and
// breathing brackets. All colors, glyphs, and copy are parameters.

import SwiftUI

/// One selectable capture mode chip (e.g. scan / barcode / label).
@available(iOS 17.0, *)
public struct CaptureModeSpec: Identifiable, Equatable {
    public var id: String
    public var label: String
    public var glyph: String?

    public init(id: String? = nil, label: String, glyph: String? = nil) {
        self.id = id ?? label
        self.label = label
        self.glyph = glyph
    }
}

@available(iOS 17.0, *)
public struct CameraCaptureScreen: View {
    /// Which overlay chrome to draw. The host flips this (usually from the
    /// mode chips) — the component never owns capture behavior.
    public enum Overlay: Equatable {
        /// Rounded near-square cutout with scan line, shutter, and gallery chip.
        case viewfinder
        /// Wide short reticle with hint label and torch chip; no shutter
        /// (barcode detection is continuous).
        case barcode
    }

    @Binding private var selectedModeID: String
    @Binding private var isTorchOn: Bool
    private let overlay: Overlay
    private let modes: [CaptureModeSpec]
    private let surroundColor: Color, bracketColor: Color, scanLineColor: Color, shutterColor: Color
    private let surroundOpacity: Double
    private let cutoutCornerRadiusOverride: CGFloat?
    private let horizontalInsetOverride: CGFloat?
    private let frameAspect: CGFloat
    private let barcodeReticleHeight: CGFloat
    private let hintText: String
    private let torchLabel: String, torchOnGlyph: String, torchOffGlyph: String
    private let torchActiveColor: Color
    private let galleryGlyph: String, shutterAccessibilityLabel: String, galleryAccessibilityLabel: String
    private let onShutter: () -> Void
    private let onGallery: () -> Void
    private let onModeChange: ((String) -> Void)?
    private let onTorchToggle: ((Bool) -> Void)?
    private let onResult: (() -> Void)?

    @State private var scanPhase = false
    @State private var shutterCount = 0
    @State private var flashOpacity: Double = 0
    @State private var reticleBreathing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        selectedModeID: Binding<String>,
        overlay: Overlay = .viewfinder,
        modes: [CaptureModeSpec] = [
            CaptureModeSpec(label: "Scan", glyph: "viewfinder"),
            CaptureModeSpec(label: "Barcode", glyph: "barcode.viewfinder"),
            CaptureModeSpec(label: "Label", glyph: "text.viewfinder")
        ],
        isTorchOn: Binding<Bool> = .constant(false),
        surroundColor: Color = .black,
        surroundOpacity: Double = 0.55,
        cutoutCornerRadius: CGFloat? = nil,
        horizontalInset: CGFloat? = nil,
        frameAspect: CGFloat = 1.08,
        barcodeReticleHeight: CGFloat = 118,
        hintText: String = "Align barcode within frame",
        torchLabel: String = "Torch",
        torchOnGlyph: String = "bolt.fill",
        torchOffGlyph: String = "bolt.slash.fill",
        torchActiveColor: Color = ClinicalTokens.warning,
        bracketColor: Color = .white,
        scanLineColor: Color = .white,
        shutterColor: Color = .white,
        galleryGlyph: String = "photo.on.rectangle.angled",
        shutterAccessibilityLabel: String = "Capture",
        galleryAccessibilityLabel: String = "Photo library",
        onShutter: @escaping () -> Void = {},
        onGallery: @escaping () -> Void = {},
        onModeChange: ((String) -> Void)? = nil,
        onTorchToggle: ((Bool) -> Void)? = nil,
        onResult: (() -> Void)? = nil
    ) {
        self._selectedModeID = selectedModeID
        self._isTorchOn = isTorchOn
        self.overlay = overlay
        self.modes = modes
        self.surroundColor = surroundColor; self.surroundOpacity = surroundOpacity
        self.cutoutCornerRadiusOverride = cutoutCornerRadius
        self.horizontalInsetOverride = horizontalInset
        self.frameAspect = frameAspect
        self.barcodeReticleHeight = barcodeReticleHeight
        self.hintText = hintText
        self.torchLabel = torchLabel
        self.torchOnGlyph = torchOnGlyph; self.torchOffGlyph = torchOffGlyph
        self.torchActiveColor = torchActiveColor
        self.bracketColor = bracketColor
        self.scanLineColor = scanLineColor; self.shutterColor = shutterColor
        self.galleryGlyph = galleryGlyph; self.shutterAccessibilityLabel = shutterAccessibilityLabel
        self.galleryAccessibilityLabel = galleryAccessibilityLabel
        self.onShutter = onShutter; self.onGallery = onGallery
        self.onModeChange = onModeChange; self.onTorchToggle = onTorchToggle
        self.onResult = onResult
    }

    /// Per-overlay geometry defaults (observed: 28 pt radius / 36 pt inset
    /// for the viewfinder cutout, 16 pt / 28 pt for the barcode reticle).
    private var cutoutCornerRadius: CGFloat {
        cutoutCornerRadiusOverride ?? (overlay == .viewfinder ? 28 : 16)
    }
    private var horizontalInset: CGFloat {
        horizontalInsetOverride ?? (overlay == .viewfinder ? 36 : 28)
    }
    private var bracketLineWidth: CGFloat { overlay == .viewfinder ? 5 : 4 }

    public var body: some View {
        GeometryReader { geo in
            let cutout = cutoutRect(in: geo.size)
            ZStack {
                surroundPath(size: geo.size, cutout: cutout)
                    .fill(surroundColor.opacity(surroundOpacity), style: FillStyle(eoFill: true))
                    .allowsHitTesting(false)
                bracketsPath(in: cutout.insetBy(dx: -2.5, dy: -2.5))
                    .stroke(bracketColor, style: StrokeStyle(lineWidth: bracketLineWidth, lineCap: .round))
                    .scaleEffect(overlay == .barcode && reticleBreathing ? 1.015 : 1.0, anchor: .center)
                    .animation(
                        overlay == .barcode && !reduceMotion
                            ? .spring(response: 1.4, dampingFraction: 0.6).repeatForever(autoreverses: true)
                            : nil,
                        value: reticleBreathing
                    )
                    .allowsHitTesting(false)
                if overlay == .viewfinder, !reduceMotion {
                    scanLine(in: cutout)
                }
                if overlay == .barcode {
                    VStack(spacing: 16) {
                        Text(hintText)
                            .font(.system(.subheadline).weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(.ultraThinMaterial))
                        torchChip
                    }
                    .position(x: cutout.midX, y: cutout.maxY + 62)
                }
                Color.white.opacity(flashOpacity).allowsHitTesting(false)
                VStack(spacing: 18) {
                    Spacer()
                    if !modes.isEmpty { modeRow }
                    if overlay == .viewfinder { controlsRow }
                }
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            scanPhase = true
            if !reduceMotion { reticleBreathing = true }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: shutterCount)
        .sensoryFeedback(.selection, trigger: selectedModeID)
        .sensoryFeedback(.selection, trigger: isTorchOn)
    }

    // MARK: Geometry

    private func cutoutRect(in size: CGSize) -> CGRect {
        let width = max(size.width - horizontalInset * 2, 0)
        switch overlay {
        case .viewfinder:
            let height = width * frameAspect
            return CGRect(x: horizontalInset, y: max((size.height - height) * 0.38, 12), width: width, height: height)
        case .barcode:
            return CGRect(x: horizontalInset,
                          y: max((size.height - barcodeReticleHeight) * 0.40, 12),
                          width: width, height: barcodeReticleHeight)
        }
    }

    private func surroundPath(size: CGSize, cutout: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(origin: .zero, size: size))
        path.addRoundedRect(in: cutout, cornerSize: CGSize(width: cutoutCornerRadius, height: cutoutCornerRadius))
        return path
    }

    /// Four rounded corner brackets: arc around each cutout corner plus
    /// tangential arms (22 pt in viewfinder; clamped to a third of the
    /// reticle height in barcode so short reticles keep open edges).
    private func bracketsPath(in rect: CGRect) -> Path {
        let r = cutoutCornerRadius
        let arm: CGFloat = overlay == .viewfinder ? 22 : min(r + 12, rect.height / 3)
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + r + arm))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addArc(center: CGPoint(x: rect.minX + r, y: rect.minY + r), radius: r, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.addLine(to: CGPoint(x: rect.minX + r + arm, y: rect.minY))
        p.move(to: CGPoint(x: rect.maxX - r - arm, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY + r), radius: r, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + r + arm))
        p.move(to: CGPoint(x: rect.maxX, y: rect.maxY - r - arm))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r), radius: r, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX - r - arm, y: rect.maxY))
        p.move(to: CGPoint(x: rect.minX + r + arm, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        p.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r), radius: r, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - r - arm))
        return p
    }

    private func scanLine(in cutout: CGRect) -> some View {
        Capsule()
            .fill(LinearGradient(
                colors: [scanLineColor.opacity(0), scanLineColor, scanLineColor.opacity(0)],
                startPoint: .leading, endPoint: .trailing
            ))
            .frame(width: cutout.width - 36, height: 3)
            .shadow(color: scanLineColor.opacity(0.7), radius: 6)
            .position(x: cutout.midX, y: scanPhase ? cutout.maxY - 20 : cutout.minY + 20)
            .animation(.linear(duration: 1.6).repeatForever(autoreverses: true), value: scanPhase)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    // MARK: Chrome

    private var modeRow: some View {
        HStack(spacing: 10) {
            ForEach(modes) { mode in
                let isSelected = mode.id == selectedModeID
                Button {
                    selectedModeID = mode.id
                    onModeChange?(mode.id)
                } label: {
                    HStack(spacing: 5) {
                        if let glyph = mode.glyph { Image(systemName: glyph) }
                        Text(mode.label)
                    }
                    .font(.system(.footnote).weight(.semibold))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Capsule().fill(isSelected ? AnyShapeStyle(shutterColor) : AnyShapeStyle(.ultraThinMaterial)))
                    .foregroundStyle(isSelected ? Color.black : Color.white)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    private var controlsRow: some View {
        HStack {
            Button(action: onGallery) {
                Image(systemName: galleryGlyph)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(galleryAccessibilityLabel)
            Spacer()
            Button(action: fireShutter) {
                ZStack {
                    Circle().stroke(shutterColor, lineWidth: 4).frame(width: 76, height: 76)
                    Circle().fill(shutterColor).frame(width: 62, height: 62)
                }
            }
            .buttonStyle(ShutterPressStyle())
            .accessibilityLabel(shutterAccessibilityLabel)
            Spacer()
            Color.clear.frame(width: 52, height: 52) // invisible twin keeps the shutter centered
        }
        .padding(.horizontal, 32)
    }

    private var torchChip: some View {
        Button {
            isTorchOn.toggle()
            onTorchToggle?(isTorchOn)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isTorchOn ? torchOnGlyph : torchOffGlyph)
                Text(torchLabel)
            }
            .font(.system(.footnote).weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(isTorchOn ? AnyShapeStyle(torchActiveColor) : AnyShapeStyle(.ultraThinMaterial))
            )
            .foregroundStyle(isTorchOn ? Color.black : Color.white)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(torchLabel)
        .accessibilityValue(isTorchOn ? "On" : "Off")
        .accessibilityAddTraits(isTorchOn ? .isSelected : [])
    }

    private func fireShutter() {
        shutterCount += 1
        onShutter()
        Task { @MainActor in
            if !reduceMotion {
                withAnimation(.linear(duration: 0.05)) { flashOpacity = 0.85 }
                try? await Task.sleep(for: .seconds(0.09))
                withAnimation(.linear(duration: 0.2)) { flashOpacity = 0 }
            }
            try? await Task.sleep(for: .seconds(0.3))
            onResult?()
        }
    }
}

@available(iOS 17.0, *)
private struct ShutterPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

@available(iOS 17.0, *)
private struct CameraCaptureScreenPreviewHost: View {
    @State private var mode = "Scan"
    @State private var torch = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            CameraCaptureScreen(selectedModeID: $mode,
                                overlay: mode == "Barcode" ? .barcode : .viewfinder,
                                isTorchOn: $torch)
        }
    }
}

#Preview("Capture over placeholder") {
    if #available(iOS 17.0, *) {
        CameraCaptureScreenPreviewHost()
    }
}
