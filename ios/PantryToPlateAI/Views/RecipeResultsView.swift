import SwiftUI

struct RecipeResultsView: View {
    @Environment(PantryStore.self) private var store
    @State private var selectedRecipe: Recipe?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xxl) {
                    resultsHero
                    dietaryFilters
                    recipeSection
                }
                .padding(.horizontal, AppTokens.Spacing.screenMargin)
                .padding(.vertical, AppTokens.Spacing.lg)
            }
            .background(AppTokens.background)
            .navigationTitle("Cook tonight")
            .toolbar {
                if !store.selectedIngredients.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: AppTokens.Spacing.xxs) {
                            Image(systemName: "leaf.fill")
                            Text("\(store.selectedIngredients.count)")
                        }
                        .font(AppTokens.headlineFont)
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }

    private var resultsHero: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
            Text("Best match")
                .font(AppTokens.captionFont)
                .foregroundStyle(AppTokens.secondaryInk)
                .textCase(.uppercase)
                .kerning(1.1)
            Text("\(store.rankedRecipes.first.map { store.matchCount(for: $0) } ?? 0) ingredients, plenty of dinner")
                .font(AppTokens.displayFont)
                .foregroundStyle(AppTokens.ink)
                .lineLimit(2)
            Text("Recipes are ranked from your confirmed scan and dietary preferences.")
                .font(AppTokens.bodyFont)
                .foregroundStyle(AppTokens.secondaryInk)
        }
    }

    private var dietaryFilters: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
            Text("Dietary fit")
                .font(AppTokens.headlineFont)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTokens.Spacing.xs) {
                    ForEach(DietaryFilter.allCases) { filter in
                        Button {
                            store.toggleFilter(filter)
                        } label: {
                            Text(filter.rawValue)
                                .font(AppTokens.captionFont)
                                .foregroundStyle(store.activeFilters.contains(filter) ? AppTokens.onAccent : AppTokens.ink)
                                .padding(.horizontal, AppTokens.Spacing.sm)
                                .frame(minHeight: 36)
                                .background(store.activeFilters.contains(filter) ? AppTokens.accent : AppTokens.surface, in: Capsule())
                                .overlay {
                                    Capsule().stroke(AppTokens.hairline, lineWidth: store.activeFilters.contains(filter) ? 0 : 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var recipeSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            Text("Recipes")
                .font(AppTokens.titleFont)
            if store.rankedRecipes.isEmpty {
                ContentUnavailableView("No matches yet", systemImage: "leaf", description: Text("Try removing a dietary filter or confirming more ingredients."))
            } else {
                ForEach(Array(store.rankedRecipes.enumerated()), id: \.element.id) { index, recipe in
                    RecipeCard(recipe: recipe, matchCount: store.matchCount(for: recipe), isFeatured: index == 0) {
                        selectedRecipe = recipe
                    }
                }
            }
        }
    }
}

struct RecipeCard: View {
    @Environment(PantryStore.self) private var store
    let recipe: Recipe
    let matchCount: Int
    let isFeatured: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTokens.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTokens.cardRadius - AppTokens.Spacing.xxs)
                        .fill(isFeatured ? AppTokens.accent : AppTokens.accent.opacity(0.15))
                    Image(systemName: recipe.heroGlyph)
                        .font(AppTokens.titleFont)
                        .foregroundStyle(isFeatured ? AppTokens.onAccent : AppTokens.accent)
                }
                .frame(width: isFeatured ? 104 : 72, height: isFeatured ? 122 : 84)

                VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                    Text(recipe.title)
                        .font(isFeatured ? AppTokens.titleFont : AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.ink)
                        .lineLimit(2)
                    Text(recipe.subtitle)
                        .font(AppTokens.captionFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                        .lineLimit(2)
                    HStack(spacing: AppTokens.Spacing.sm) {
                        Label("\(matchCount)/\(recipe.ingredients.count)", systemImage: "checkmark.circle.fill")
                        Label("\(recipe.macros.protein)g", systemImage: "bolt.fill")
                        Label("\(recipe.duration) min", systemImage: "clock")
                    }
                    .font(AppTokens.captionFont)
                    .foregroundStyle(AppTokens.secondaryInk)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(AppTokens.captionFont.weight(.bold))
                    .foregroundStyle(AppTokens.secondaryInk)
            }
            .padding(AppTokens.Spacing.sm)
            .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius))
        }
        .buttonStyle(.plain)
    }
}
