import SwiftUI

struct PantryView: View {
    @Environment(PantryStore.self) private var store

    var body: some View {
        NavigationStack {
            List {
                Section {
                    pantrySummary
                        .listRowInsets(EdgeInsets(top: AppTokens.Spacing.md, leading: AppTokens.Spacing.screenMargin, bottom: AppTokens.Spacing.md, trailing: AppTokens.Spacing.screenMargin))
                        .listRowBackground(AppTokens.background)
                }
                Section("On hand") {
                    ForEach(store.pantryIngredients) { ingredient in
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
                        }
                        .padding(.vertical, AppTokens.Spacing.xxs)
                    }
                }
                Section("Recent scans") {
                    ForEach(store.scanHistory) { record in
                        VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                            Text(record.recipeName)
                                .font(AppTokens.headlineFont)
                            Text(record.ingredients.joined(separator: " · "))
                                .font(AppTokens.captionFont)
                                .foregroundStyle(AppTokens.secondaryInk)
                                .lineLimit(2)
                        }
                        .padding(.vertical, AppTokens.Spacing.xxs)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTokens.background)
            .navigationTitle("Pantry")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: AppTokens.Spacing.xxs) {
                        Image(systemName: "leaf.fill")
                        Text("\(store.pantryIngredients.count)")
                    }
                    .font(AppTokens.headlineFont)
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
    }

    private var pantrySummary: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
            Text("Ready to cook")
                .font(AppTokens.titleFont)
            Text("\(store.pantryIngredients.count) ingredients are on hand and ready to match against your next scan.")
                .font(AppTokens.bodyFont)
                .foregroundStyle(AppTokens.secondaryInk)
        }
        .padding(AppTokens.Spacing.md)
        .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius))
    }
}

struct SavedView: View {
    @Environment(PantryStore.self) private var store
    @State private var selectedRecipe: Recipe?

    private var savedRecipes: [Recipe] {
        PantryStore.recipes.filter { store.favoriteRecipeIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                    if savedRecipes.isEmpty {
                        ContentUnavailableView("No saved recipes", systemImage: "heart", description: Text("Save a cook-tonight recipe to keep it close."))
                            .padding(.top, AppTokens.Spacing.huge)
                    } else {
                        Text("Keep your reliable dinner ideas close.")
                            .font(AppTokens.bodyFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                        ForEach(Array(savedRecipes.enumerated()), id: \.element.id) { index, recipe in
                            RecipeCard(recipe: recipe, matchCount: store.matchCount(for: recipe), isFeatured: index == 0) {
                                selectedRecipe = recipe
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTokens.Spacing.screenMargin)
                .padding(.vertical, AppTokens.Spacing.lg)
            }
            .background(AppTokens.background)
            .navigationTitle("Saved")
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
