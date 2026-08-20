import SwiftUI

struct ScanView: View {
    @Environment(PantryStore.self) private var store
    @State private var captureMode = "Scan"
    @State private var isTorchOn = false
    @State private var isProcessing = false
    @State private var showIngredients = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTokens.background
                    .ignoresSafeArea()

                VStack(spacing: AppTokens.Spacing.xl) {
                    scanPreview
                    scanContext
                    recentMatch
                }
                .padding(.horizontal, AppTokens.Spacing.screenMargin)
                .padding(.vertical, AppTokens.Spacing.lg)
            }
            .navigationTitle("Scan")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showIngredients = true
                    } label: {
                        Image(systemName: "basket.fill")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Review detected ingredients")
                }
            }
            .sheet(isPresented: $showIngredients) {
                IngredientReviewSheet()
            }
        }
    }

    private var scanPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTokens.tileRadius)
                .fill(
                    LinearGradient(
                        colors: [AppTokens.ink, AppTokens.ink.opacity(0.80)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(maxWidth: .infinity)
                .aspectRatio(0.84, contentMode: .fit)

            VStack(spacing: AppTokens.Spacing.md) {
                Image(systemName: isProcessing ? "sparkles" : "refrigerator.fill")
                    .font(AppTokens.displayFont)
                    .foregroundStyle(AppTokens.onAccent)
                    .symbolEffect(.pulse, isActive: isProcessing)

                Text(isProcessing ? "Finding ingredients" : "Frame your ingredients")
                    .font(AppTokens.titleFont)
                    .foregroundStyle(AppTokens.onAccent)

                Text(isProcessing ? "Checking your photo…" : "Open your fridge or pantry for a quick scan")
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.onAccent.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTokens.Spacing.xl)
            }

            CameraCaptureScreen(
                selectedModeID: $captureMode,
                modes: [CaptureModeSpec(label: "Scan", glyph: "viewfinder")],
                isTorchOn: $isTorchOn,
                surroundColor: .clear,
                surroundOpacity: 0,
                bracketColor: AppTokens.accent,
                scanLineColor: AppTokens.accent,
                shutterColor: AppTokens.onAccent,
                onShutter: startMockScan,
                onGallery: startMockScan
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTokens.tileRadius))
        .overlay(alignment: .bottom) {
            Text("Local demo · simulated ingredient recognition")
                .font(AppTokens.captionFont)
                .foregroundStyle(AppTokens.onAccent.opacity(0.76))
                .padding(.bottom, AppTokens.Spacing.sm)
        }
    }

    private var scanContext: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
            Text("Cook from what you have")
                .font(AppTokens.titleFont)
                .foregroundStyle(AppTokens.ink)
            Text("Scan the ingredients in view, then confirm them before we rank cook-tonight recipes around your dietary fit.")
                .font(AppTokens.bodyFont)
                .foregroundStyle(AppTokens.secondaryInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recentMatch: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
            HStack {
                Text("Last scan")
                    .font(AppTokens.headlineFont)
                Spacer()
                Text("5 ingredients")
                    .font(AppTokens.captionFont)
                    .foregroundStyle(AppTokens.secondaryInk)
            }
            HStack(spacing: AppTokens.Spacing.sm) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(AppTokens.titleFont)
                    .foregroundStyle(AppTokens.accent)
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                    Text(store.scanHistory.first?.recipeName ?? "Ginger salmon grain bowl")
                        .font(AppTokens.headlineFont)
                        .lineLimit(2)
                    Text("Ready in 25 min · gluten-free")
                        .font(AppTokens.captionFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                }
                Spacer()
            }
        }
        .padding(AppTokens.Spacing.md)
        .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius))
    }

    private func startMockScan() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isProcessing = false
            showIngredients = true
        }
    }
}

struct IngredientReviewSheet: View {
    @Environment(PantryStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                        header
                        ingredientList
                        disclosure
                    }
                    .padding(.horizontal, AppTokens.Spacing.screenMargin)
                    .padding(.top, AppTokens.Spacing.lg)
                }
            }
            .navigationTitle("Detected ingredients")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        store.confirmScan()
                        dismiss()
                    }
                    .font(AppTokens.headlineFont)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button {
                    store.confirmScan()
                    dismiss()
                } label: {
                    Text("Find recipes for \(store.selectedIngredients.count) ingredients")
                }
                .buttonStyle(PrimaryCTAStyle())
                .padding(.horizontal, AppTokens.Spacing.screenMargin)
                .padding(.vertical, AppTokens.Spacing.sm)
                .background(AppTokens.background)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
            Text("Your photo looks good")
                .font(AppTokens.titleFont)
            Text("Tap anything that is not on hand. These choices drive every recipe match.")
                .font(AppTokens.bodyFont)
                .foregroundStyle(AppTokens.secondaryInk)
        }
    }

    private var ingredientList: some View {
        VStack(spacing: AppTokens.Spacing.xs) {
            ForEach(store.scanCandidates) { ingredient in
                Button {
                    store.toggleIngredient(ingredient)
                } label: {
                    HStack(spacing: AppTokens.Spacing.sm) {
                        Image(systemName: ingredient.glyph)
                            .foregroundStyle(AppTokens.accent)
                            .frame(width: 32, height: 32)
                            .background(AppTokens.accent.opacity(0.12), in: Circle())
                        VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                            Text(ingredient.name)
                                .font(AppTokens.headlineFont)
                            Text(ingredient.category)
                                .font(AppTokens.captionFont)
                                .foregroundStyle(AppTokens.secondaryInk)
                        }
                        Spacer()
                        Image(systemName: store.selectedIngredientIDs.contains(ingredient.id) ? "checkmark.circle.fill" : "circle")
                            .font(AppTokens.headlineFont)
                            .foregroundStyle(store.selectedIngredientIDs.contains(ingredient.id) ? AppTokens.accent : AppTokens.hairline)
                    }
                    .padding(AppTokens.Spacing.sm)
                    .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var disclosure: some View {
        Label("Recognition is an on-device scripted demo; no vision service is connected.", systemImage: "info.circle")
            .font(AppTokens.captionFont)
            .foregroundStyle(AppTokens.secondaryInk)
    }
}
