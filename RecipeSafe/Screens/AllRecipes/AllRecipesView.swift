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
    
    @State var navPath: NavigationPath
    @State var searchText: String = ""
    @State var customRecipeSheet: Bool = false
    
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
            
            GeometryReader { geo in
                
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
                .applyAppBackground(proxy: geo, isShown: !recipeList.isEmpty)
                .navigationTitle("content.nav.title".localized)
                .toolbar {
                    ToolbarItem {
                        Button{
                            customRecipeSheet = true
                        } label: {
                            Label("content.toolbar.add".localized, systemImage: "plus")
                                .frame(width: 40, height: 40)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
            
            // MARK: - Navigation
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeView(recipe: recipe, screen: .allRecipes)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .searchable(text: $searchText, prompt: "content.search.prompt".localized)
        .sheet(isPresented: $customRecipeSheet) {
            NavigationView {
                RecipeView(recipe: Recipe(), screen: .allRecipes, createNew: true)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AllRecipesView(navPath: .init())
        .injectServices(ServiceDependencies(session: URLSession.shared))
}

