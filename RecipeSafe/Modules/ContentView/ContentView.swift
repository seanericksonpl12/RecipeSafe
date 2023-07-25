//
//  ContentView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var recipeList: FetchedResults<RecipeItem>
    
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    
    var body: some View {
        
        switch viewModel.viewState {
        case .loading:
            LoadingView()
        case .successfullyLoaded, .started, .failedToLoad:
            listView
        }
    }
    
    var listView: some View {
        NavigationStack(path: $viewModel.navPath) {
            
            List {
                ForEach(recipeList, id: \.id) { item in
                    NavigationLink {
                        if let recipe = Recipe(dataItem: item) {
                            RecipeView(viewModel: RecipeViewModel(recipe: recipe))
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    } label: {
                        Text(item.title ?? "")
                    }
                }
                .onDelete {
                    viewModel.deleteItem(offset: $0,
                                         list: recipeList,
                                         context: viewContext)
                }
                
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeView(viewModel: RecipeViewModel(recipe: recipe))
                    .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar {
                ToolbarItem {
                    Button{
                        viewModel.addItem(context: self.viewContext)
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .onOpenURL { url in
                viewModel.onURLOpen(url: url.absoluteString)
            }
            .alert("Couldn't Curate Recipe", isPresented: $viewModel.displayBadSite) {
                Button("OK") { viewModel.displayBadSite = false }
            } message: {
                Text("Please try a different site or create your own recipe")
            }
            .alert("Recipe Already Exists", isPresented: $viewModel.duplicateFound) {
                Button("Overwrite") {
                    viewModel.overwriteRecipe(deletingDup: true)
                }
                Button("Save Copy") {
                    viewModel.overwriteRecipe()
                }
                Button("Cancel") {
                    viewModel.cancelOverwrite()
                }
            } message: {
                Text("Would you like to overwrite it or save a new copy?")
            }
            
            Text("Select an item")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
