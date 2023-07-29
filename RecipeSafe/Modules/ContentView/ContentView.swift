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
    
    @StateObject var viewModel: ContentViewModel
    
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
            
            if recipeList.isEmpty {
                EmptyListView()
                    .padding()
            }
            
            List {
                ForEach(viewModel.searchList(recipeList), id: \.id) { item in
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
            .navigationTitle("content.nav.title".localized)
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
                        Label("content.toolbar.add".localized, systemImage: "plus")
                    }
                }
                ToolbarItem {
                    Button("Test") {
                        viewModel.gpt.testNewGPT()
                    }
                }
            }
            .onOpenURL { url in
                viewModel.onURLOpen(url: url.absoluteString)
            }
            .alert("content.alert.fail.title".localized, isPresented: $viewModel.displayBadSite) {
                Button("button.ok".localized) { viewModel.displayBadSite = false }
            } message: {
                Text("content.alert.fail.desc".localized)
            }
            .alert("content.alert.copy.title".localized, isPresented: $viewModel.duplicateFound) {
                Button("button.overwrite".localized) {
                    viewModel.overwriteRecipe(deletingDup: true)
                }
                Button("button.savecopy".localized) {
                    viewModel.overwriteRecipe()
                }
                Button("button.cancel".localized) {
                    viewModel.cancelOverwrite()
                }
            } message: {
                Text("content.alert.copy.desc".localized)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "content.search.prompt".localized)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
