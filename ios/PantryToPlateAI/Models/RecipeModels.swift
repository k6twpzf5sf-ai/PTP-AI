import Foundation

struct Ingredient: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let glyph: String
}

struct MacroProfile: Hashable {
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

struct Recipe: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let heroGlyph: String
    let duration: Int
    let servings: Int
    let macros: MacroProfile
    let ingredients: [String]
    let dietTags: Set<DietaryFilter>
    let steps: [String]
    let note: String
}

enum DietaryFilter: String, CaseIterable, Identifiable, Hashable {
    case vegetarian = "Vegetarian"
    case glutenFree = "Gluten-free"
    case dairyFree = "Dairy-free"
    case nutFree = "Nut-free"

    var id: String { rawValue }
}

struct ScanRecord: Identifiable {
    let id = UUID()
    let date: Date
    let ingredients: [String]
    let recipeName: String
}
