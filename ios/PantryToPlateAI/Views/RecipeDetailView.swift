import SwiftUI

struct RecipeDetailView: View {
    @Environment(PantryStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let recipe: Recipe

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xxl) {
                    hero
                    macroRow
                    ingredientSection
                    directionsSection
                    chefNote
                }
                .padding(.horizontal, AppTokens.Spacing.screenMargin)
                .padding(.vertical, AppTokens.Spacing.lg)
            }
            .background(AppTokens.background)
            .navigationTitle("Recipe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 44, height: 44)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.toggleFavorite(recipe)
                    } label: {
                        Image(systemName: store.favoriteRecipeIDs.contains(recipe.id) ? "heart.fill" : "heart")
                            .foregroundStyle(store.favoriteRecipeIDs.contains(recipe.id) ? AppTokens.warning : AppTokens.ink)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Save recipe")
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Label("Start cooking", systemImage: "fork.knife")
                }
                .buttonStyle(PrimaryCTAStyle())
                .padding(.horizontal, AppTokens.Spacing.screenMargin)
                .padding(.vertical, AppTokens.Spacing.sm)
                .background(AppTokens.background)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTokens.tileRadius)
                    .fill(
                        LinearGradient(
                            colors: [AppTokens.accent, AppTokens.accent.opacity(0.62)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: recipe.heroGlyph)
                    .font(.system(size: 64, weight: .bold, design: .default))
                    .foregroundStyle(AppTokens.onAccent)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.5, contentMode: .fit)

            Text(recipe.title)
                .font(AppTokens.displayFont)
                .foregroundStyle(AppTokens.ink)
                .lineLimit(2)
            Text(recipe.subtitle)
                .font(AppTokens.bodyFont)
                .foregroundStyle(AppTokens.secondaryInk)
            HStack(spacing: AppTokens.Spacing.md) {
                Label("\(recipe.duration) min", systemImage: "clock")
                Label("Serves \(recipe.servings)", systemImage: "person.2")
                Label("\(store.matchCount(for: recipe))/\(recipe.ingredients.count) on hand", systemImage: "checkmark.circle.fill")
            }
            .font(AppTokens.captionFont)
            .foregroundStyle(AppTokens.secondaryInk)
        }
    }

    private var macroRow: some View {
        HStack(spacing: AppTokens.Spacing.sm) {
            MacroMetric(value: "\(recipe.macros.calories)", label: "kcal")
            MacroMetric(value: "\(recipe.macros.protein)g", label: "protein")
            MacroMetric(value: "\(recipe.macros.carbs)g", label: "carbs")
            MacroMetric(value: "\(recipe.macros.fat)g", label: "fat")
        }
    }

    private var ingredientSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            Text("Ingredients")
                .font(AppTokens.titleFont)
            ForEach(recipe.ingredients, id: \.self) { ingredient in
                let hasIngredient = !store.missingIngredients(for: recipe).contains(ingredient)
                HStack(spacing: AppTokens.Spacing.sm) {
                    Image(systemName: hasIngredient ? "checkmark.circle.fill" : "cart.badge.plus")
                        .foregroundStyle(hasIngredient ? AppTokens.positive : AppTokens.warning)
                    Text(ingredient)
                        .font(AppTokens.bodyFont)
                    Spacer()
                    Text(hasIngredient ? "On hand" : "Need")
                        .font(AppTokens.captionFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                }
                .padding(AppTokens.Spacing.sm)
                .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius))
            }
        }
    }

    private var directionsSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            Text("Method")
                .font(AppTokens.titleFont)
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: AppTokens.Spacing.sm) {
                    Text("\(index + 1)")
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.onAccent)
                        .frame(width: 32, height: 32)
                        .background(AppTokens.accent, in: Circle())
                    Text(step)
                        .font(AppTokens.bodyFont)
                        .foregroundStyle(AppTokens.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var chefNote: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
            Label("Kitchen note", systemImage: "lightbulb.fill")
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.accent)
            Text(recipe.note)
                .font(AppTokens.bodyFont)
                .foregroundStyle(AppTokens.secondaryInk)
        }
        .padding(AppTokens.Spacing.md)
        .background(AppTokens.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: AppTokens.cardRadius))
    }
}

private struct MacroMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
            Text(value)
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.ink)
                .monospacedDigit()
            Text(label)
                .font(AppTokens.captionFont)
                .foregroundStyle(AppTokens.secondaryInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTokens.Spacing.sm)
        .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius))
    }
}
