import Foundation
import Observation

@Observable
final class PantryStore {
    var pantryIngredients: [Ingredient] = PantryStore.seedIngredients
    var scanCandidates: [Ingredient] = PantryStore.scanIngredients
    var selectedIngredientIDs: Set<String> = Set(PantryStore.scanIngredients.map(\.id))
    var activeFilters: Set<DietaryFilter> = [.glutenFree]
    var favoriteRecipeIDs: Set<String> = ["ginger-salmon-bowl"]
    var scanHistory: [ScanRecord] = [
        ScanRecord(date: .now.addingTimeInterval(-86_400), ingredients: ["Salmon", "Spinach", "Lemon"], recipeName: "Lemony salmon greens"),
        ScanRecord(date: .now.addingTimeInterval(-259_200), ingredients: ["Chickpeas", "Tomatoes", "Avocado"], recipeName: "Smoky chickpea salad"),
        ScanRecord(date: .now.addingTimeInterval(-432_000), ingredients: ["Eggs", "Mushrooms", "Spinach"], recipeName: "Herby skillet eggs")
    ]

    static let seedIngredients: [Ingredient] = [
        Ingredient(id: "salmon", name: "Salmon fillet", category: "Protein", glyph: "fish.fill"),
        Ingredient(id: "spinach", name: "Baby spinach", category: "Produce", glyph: "leaf.fill"),
        Ingredient(id: "lemon", name: "Lemon", category: "Produce", glyph: "sun.max.fill"),
        Ingredient(id: "avocado", name: "Avocado", category: "Produce", glyph: "leaf.circle.fill"),
        Ingredient(id: "yogurt", name: "Greek yogurt", category: "Dairy", glyph: "cup.and.saucer.fill"),
        Ingredient(id: "chickpeas", name: "Chickpeas", category: "Pantry", glyph: "circle.grid.cross.fill"),
        Ingredient(id: "eggs", name: "Eggs", category: "Protein", glyph: "oval.fill"),
        Ingredient(id: "rice", name: "Brown rice", category: "Pantry", glyph: "takeoutbag.and.cup.and.straw.fill")
    ]

    static let scanIngredients: [Ingredient] = [
        Ingredient(id: "salmon", name: "Salmon fillet", category: "Protein", glyph: "fish.fill"),
        Ingredient(id: "spinach", name: "Baby spinach", category: "Produce", glyph: "leaf.fill"),
        Ingredient(id: "lemon", name: "Lemon", category: "Produce", glyph: "sun.max.fill"),
        Ingredient(id: "avocado", name: "Avocado", category: "Produce", glyph: "leaf.circle.fill"),
        Ingredient(id: "rice", name: "Brown rice", category: "Pantry", glyph: "takeoutbag.and.cup.and.straw.fill")
    ]

    static let recipes: [Recipe] = [
        Recipe(id: "ginger-salmon-bowl", title: "Ginger salmon grain bowl", subtitle: "Crisp greens, citrus, and a creamy yogurt drizzle", heroGlyph: "fork.knife.circle.fill", duration: 25, servings: 2, macros: MacroProfile(calories: 548, protein: 38, carbs: 48, fat: 23), ingredients: ["Salmon fillet", "Baby spinach", "Lemon", "Avocado", "Brown rice", "Greek yogurt"], dietTags: [.glutenFree, .nutFree], steps: ["Warm the brown rice with a splash of water until steamy.", "Season salmon with lemon zest, ginger, salt, and pepper; sear skin-side down for 4 minutes.", "Flip salmon and cook until just opaque in the center.", "Layer rice, spinach, avocado, and salmon. Finish with yogurt, lemon juice, and black pepper."], note: "You already have 5 of 6 ingredients. Swap yogurt for tahini to make it dairy-free."),
        Recipe(id: "chickpea-skillet", title: "Smoky chickpea skillet", subtitle: "A fast, pantry-led dinner with wilted greens", heroGlyph: "flame.fill", duration: 18, servings: 2, macros: MacroProfile(calories: 416, protein: 19, carbs: 55, fat: 14), ingredients: ["Chickpeas", "Baby spinach", "Lemon", "Avocado"], dietTags: [.vegetarian, .glutenFree, .dairyFree, .nutFree], steps: ["Crisp chickpeas in olive oil with smoked paprika.", "Fold in spinach and cook just until wilted.", "Finish with lemon juice, avocado, and a pinch of salt."], note: "Everything is already in your kitchen."),
        Recipe(id: "green-eggs", title: "Green skillet eggs", subtitle: "Soft eggs over lemony spinach and rice", heroGlyph: "leaf.circle.fill", duration: 15, servings: 2, macros: MacroProfile(calories: 392, protein: 24, carbs: 35, fat: 18), ingredients: ["Eggs", "Baby spinach", "Lemon", "Brown rice", "Greek yogurt"], dietTags: [.vegetarian, .glutenFree, .nutFree], steps: ["Warm rice in a wide skillet.", "Add spinach and lemon juice until just wilted.", "Crack in eggs, cover, and cook until whites are set.", "Serve with a spoonful of Greek yogurt."], note: "One ingredient short: eggs. Everything else is ready."),
        Recipe(id: "salmon-salad", title: "Citrus salmon salad", subtitle: "Bright, high-protein greens for a light night", heroGlyph: "leaf.fill", duration: 16, servings: 2, macros: MacroProfile(calories: 364, protein: 34, carbs: 16, fat: 20), ingredients: ["Salmon fillet", "Baby spinach", "Lemon", "Avocado"], dietTags: [.glutenFree, .dairyFree, .nutFree], steps: ["Pan-sear salmon until crisp and flaky.", "Toss spinach with lemon juice and olive oil.", "Top greens with avocado and warm salmon."], note: "Everything is already in your kitchen."),
        Recipe(id: "avocado-rice", title: "Charred avocado rice", subtitle: "Herby rice bowls with crisp chickpeas", heroGlyph: "bowl.fill", duration: 22, servings: 2, macros: MacroProfile(calories: 452, protein: 15, carbs: 62, fat: 17), ingredients: ["Brown rice", "Avocado", "Chickpeas", "Lemon", "Baby spinach"], dietTags: [.vegetarian, .glutenFree, .dairyFree, .nutFree], steps: ["Crisp chickpeas in a hot skillet.", "Warm rice with lemon zest.", "Build bowls with spinach, avocado, rice, and chickpeas."], note: "You already have 4 of 5 ingredients. Add chickpeas if they are not in your pantry."),
        Recipe(id: "creamy-salmon", title: "Creamy salmon greens", subtitle: "A cozy one-pan dinner with yogurt and lemon", heroGlyph: "sparkles", duration: 20, servings: 2, macros: MacroProfile(calories: 486, protein: 36, carbs: 22, fat: 28), ingredients: ["Salmon fillet", "Baby spinach", "Greek yogurt", "Lemon"], dietTags: [.glutenFree, .nutFree], steps: ["Sear salmon until golden and set aside.", "Wilt spinach in the same pan.", "Stir yogurt and lemon into the pan off heat, then return salmon to coat."], note: "Everything is already in your kitchen." )
    ]

    var selectedIngredients: [Ingredient] {
        scanCandidates.filter { selectedIngredientIDs.contains($0.id) }
    }

    var rankedRecipes: [Recipe] {
        let selectedNames = Set(selectedIngredients.map(\.name))
        let matchingDiet = PantryStore.recipes.filter { recipe in
            activeFilters.isSubset(of: recipe.dietTags)
        }
        return matchingDiet.sorted { first, second in
            matchCount(for: first, names: selectedNames) > matchCount(for: second, names: selectedNames)
        }
    }

    func matchCount(for recipe: Recipe) -> Int {
        matchCount(for: recipe, names: Set(selectedIngredients.map(\.name)))
    }

    func missingIngredients(for recipe: Recipe) -> [String] {
        let selectedNames = Set(selectedIngredients.map(\.name))
        return recipe.ingredients.filter { !selectedNames.contains($0) }
    }

    func toggleIngredient(_ ingredient: Ingredient) {
        if selectedIngredientIDs.contains(ingredient.id) {
            selectedIngredientIDs.remove(ingredient.id)
        } else {
            selectedIngredientIDs.insert(ingredient.id)
        }
    }

    func toggleFilter(_ filter: DietaryFilter) {
        if activeFilters.contains(filter) {
            activeFilters.remove(filter)
        } else {
            activeFilters.insert(filter)
        }
    }

    func toggleFavorite(_ recipe: Recipe) {
        if favoriteRecipeIDs.contains(recipe.id) {
            favoriteRecipeIDs.remove(recipe.id)
        } else {
            favoriteRecipeIDs.insert(recipe.id)
        }
    }

    func confirmScan() {
        for ingredient in selectedIngredients where !pantryIngredients.contains(ingredient) {
            pantryIngredients.append(ingredient)
        }
        if let topRecipe = rankedRecipes.first {
            scanHistory.insert(ScanRecord(date: .now, ingredients: selectedIngredients.map(\.name), recipeName: topRecipe.title), at: 0)
        }
    }

    private func matchCount(for recipe: Recipe, names: Set<String>) -> Int {
        recipe.ingredients.filter { names.contains($0) }.count
    }
}
