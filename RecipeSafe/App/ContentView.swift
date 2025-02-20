//
//  ContentView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/30/24.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.services.network.buildRecipe) var buildRecipe
    @Environment(\.services.recipeData) var dataService
    @Environment(\.services.groupData) var groupDataService
    
    @State var viewState: ViewState = .started
    @State var tabSelection: Int = 1
    @State var displayBadSite: Bool = false
    @State var duplicateFound: Bool = false
    @State var launchTutorial: Bool = false
    @State var allRecipesNavPath: NavigationPath = .init()
    @State var groupNavPath: NavigationPath = .init()
    @State var newRecipe: Recipe? = nil
    @State var newRecipeSwitch: Bool = false
    @State private var fetchedRecipe: Recipe?
    @State private var waitingRecipe = Recipe()
    @State private var waitingDuplicate: RecipeItem?
    
    var content: some View {
        TabView(selection: $tabSelection) {
            AllRecipesView(navPath: allRecipesNavPath)
                .tabItem {
                    Label("app.all".localized, systemImage: "line.3.horizontal")
                }
                .tag(1)
            GroupGridView(navPath: $groupNavPath, newRecipe: $newRecipe, newRecipeSwitch: $newRecipeSwitch)
                .tabItem {
                    Label("app.group".localized, systemImage: "circlebadge.2")
                }
                .tag(2)
            ShoppingListView()
                .tabItem {
                    Label("app.shopping".localized, systemImage: "list.clipboard")
                }
                .tag(3)
        }
    }
    
    var body: some View {
        Group {
            switch viewState {
            case .started, .successfullyLoaded, .failedToLoad:
                content
            case .loading:
                LoadingView()
            }
        }
        .onOpenURL { url in
            print("opening...")
            self.onURLOpen(url: url)
        }
        .alert("content.alert.fail.title".localized, isPresented: $displayBadSite) {
            Button("button.ok".localized) { displayBadSite = false }
        } message: {
            Text("content.alert.fail.desc".localized)
        }
        .alert("content.alert.copy.title".localized, isPresented: $duplicateFound) {
            Button("button.overwrite".localized) {
                overwriteRecipe(deletingDup: true)
            }
            Button("button.savecopy".localized) {
                overwriteRecipe()
            }
            Button("button.cancel".localized) {
                cancelOverwrite()
            }
        } message: {
            Text("content.alert.copy.desc".localized)
        }
        .popover(isPresented: $launchTutorial) {
            TutorialView(dismiss: $launchTutorial)
        }
        .onAppear {
            let tabBar = UITabBarAppearance()
            tabBar.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBar
        }
    }
}

extension ContentView {
    
    func overwriteRecipe(deletingDup: Bool = false) {
        if let dup = waitingDuplicate, deletingDup {
            try? self.dataService.deleteItem(dup)
        }
        self.waitingRecipe.dataEntity = try? self.dataService.save(self.waitingRecipe)?.objectID
        self.waitingDuplicate = nil
        self.openRecipe(self.waitingRecipe)
    }
    
    func cancelOverwrite() {
        self.waitingDuplicate = nil
        self.duplicateFound = false
    }
    
    func onURLOpen(url: URL) {
        self.viewState = .loading
        Task { @MainActor in
            do {
                let recipe = try await buildRecipe(url)
                self.handleNewRecipe(recipe)
            } catch {
                self.handleFailure()
            }
        }
    }
    
    // MARK: - Handle Failure
    private func handleFailure() {
        self.viewState = .failedToLoad
        self.displayBadSite = true
    }
    
    // MARK: - Handle Recipe
    private func handleNewRecipe(_ recipe: Recipe) {
        self.viewState = .successfullyLoaded
        var newRecipe = recipe
        if let duplicate = try? dataService.findDuplicates(newRecipe) {
            self.duplicateFound = true
            self.waitingRecipe = newRecipe
            self.waitingDuplicate = duplicate
        } else {
            newRecipe.dataEntity = try? dataService.save(recipe)?.objectID
            self.openRecipe(newRecipe)
        }
    }
    
    // MARK: - Open Recipe
    @MainActor
    private func openRecipe(_ recipe: Recipe) {
        let groups: [GroupItem] = (try? groupDataService.fetch()) ?? []
        if groups.isEmpty {
            self.tabSelection = 1
            self.allRecipesNavPath = NavigationPath([recipe])
        } else {
            self.tabSelection = 2
            self.groupNavPath = .init()
            self.newRecipe = recipe
            Task { @MainActor in
                self.newRecipeSwitch = true
            }
        }
    }
}

#Preview {
    ContentView()
}
