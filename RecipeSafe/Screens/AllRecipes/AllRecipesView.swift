//
//  ContentView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI
import CoreData

struct AllRecipesView: View {
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)]
    ) private var recipeList: FetchedResults<RecipeItem>
    
    @Environment(\.services.recipeData.deleteRecipes) var delete
    @Environment(\.services.network.recipeImage) var createRecipe
    @Environment(\.appConfig.featureFlags.recipeAnalysisEnabled) var cameraEnabled
    @Environment(\.services.analytics) var analytics
    
    @State var navPath: NavigationPath
    @State var searchText: String = ""
    @State var customRecipeSheet: Bool = false
    @State var photoData: Data?
    @State var isLoading: Bool = false
    @State var isFromCreateNew: Bool = false
    
    var searchList: (any RandomAccessCollection<RecipeItem>) -> [RecipeItem] {
        { [self] list in
            if searchText.isEmpty {
                return Array(list)
            } else {
                return list.filter({ $0.title?.lowercased().contains(searchText.lowercased()) ?? false })
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        
        NavigationStack(path: $navPath) {
            
            if recipeList.isEmpty {
                EmptyListView(description: "empty.desc.1".localized)
                    .padding()
            }
            
            // MARK: - List
            List {
                ForEach(searchList(recipeList), id: \.id) { item in
                    NavigationLink {
                        if let recipe = Recipe(dataItem: item) {
                            RecipeView(recipe: recipe, screen: .allRecipes)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    } label: {
                        Text(item.title ?? "")
                    }
                }
                .onDelete {
                    navPath = .init()
                    try? delete($0, recipeList)
                }
                .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
                
                if searchList(recipeList).isEmpty {
                    Spacer()
                        .listRowBackground(Color.clear)
                }
                
            }
            .scrollContentBackground(.hidden)
            .disabled(isLoading)
            .navigationTitle("content.nav.title".localized)
            .toolbar {
                ToolbarItem {
                    if cameraEnabled {
                        CreateRecipeMenuView(createFromScratch: $customRecipeSheet, photoData: $photoData)
                    } else {
                        Button {
                            customRecipeSheet = true
                            analytics.trackAction(.tappedCreateNewRecipe, analytics.currentPath)
                        } label: {
                            Label("content.toolbar.add".localized, systemImage: "plus")
                                .frame(width: 40, height: 40)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
            .onChange(of: self.photoData) { _, data in
                buildRecipeFromImage(image: data)
            }
            .overlay {
                if isLoading {
                    HStack {
                        Spacer()
                        LoadingView()
                        Spacer()
                    }
                    
                }
            }
            
            // MARK: - Navigation
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeView(recipe: recipe, screen: .allRecipes, createNew: isFromCreateNew)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .searchable(text: $searchText, prompt: "content.search.prompt".localized)
        .sheet(isPresented: $customRecipeSheet) {
            NavigationView {
                RecipeView(recipe: Recipe(), screen: .allRecipes, createNew: true)
            }
        }
        .pageLoad(.allRecipes)
    }
    
    func buildRecipeFromImage(image: Data?) {
        guard let image else { return }
        self.photoData = nil
        Task {
            self.isLoading = true
            defer { self.isLoading = false }
            
            do {
                let recipe = try await createRecipe(image)
                self.isFromCreateNew = true
                navPath.append(recipe)
            } catch {
                print("error building recipe: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview("Camera disabled") {
    AllRecipesView(navPath: .init())
        .injectServices()
}

#Preview("Camera Enabled") {
    AllRecipesView(navPath: .init())
        .injectServices()
        .environment(\.appConfig.featureFlags.recipeAnalysisEnabled, true)
}
