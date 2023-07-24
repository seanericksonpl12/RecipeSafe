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
        
        
        NavigationStack(path: $viewModel.navPath) {
            
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
                .onDelete {
                    viewModel.deleteItem(offset: $0,
                                         list: recipeList,
                                         context: viewContext)
                }
                
            }
            .navigationTitle("Recipes")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeView(recipe: recipe)
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
            Text("Select an item")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
