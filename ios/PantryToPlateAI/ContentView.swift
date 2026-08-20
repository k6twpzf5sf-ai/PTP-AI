import SwiftUI

struct ContentView: View {
    @State private var store = PantryStore()

    var body: some View {
        TabView {
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "viewfinder")
                }
            RecipeResultsView()
                .tabItem {
                    Label("Cook", systemImage: "fork.knife")
                }
            PantryView()
                .tabItem {
                    Label("Pantry", systemImage: "basket.fill")
                }
            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "heart")
                }
        }
        .tint(AppTokens.accent)
        .environment(store)
        .preferredColorScheme(.light)
    }
}
