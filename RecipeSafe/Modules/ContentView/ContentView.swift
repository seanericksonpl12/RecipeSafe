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
        sortDescriptors: [],
        animation: .default) private var recipeList: FetchedResults<RecipeItem>
    
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    
    var body: some View {
        
        
        NavigationStack(path: $viewModel.navPath) {
            Text("Recipes")
                .onOpenURL { url in
                    viewModel.onURLOpen(url: url.absoluteString)
                }
                .navigationDestination(for: Recipe.self) { recipe in
                    RecipeView(recipe: recipe)
                }
            
            
            List {
                ForEach(recipeList, id: \.id) { item in
                    NavigationLink {
                        if let recipe = Recipe(dataItem: item) {
                            RecipeView(recipe: recipe)
                        } else {
                            // TODO: - Replace with error screen
                            EmptyView()
                        }
                    } label: {
                        Text(item.title ?? "")
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteItems(context: self.viewContext, list: recipeList, offsets: indexSet)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button{
                        viewModel.addItem(context: self.viewContext)
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
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
