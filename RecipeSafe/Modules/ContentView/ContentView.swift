//
//  ContentView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    // MARK: - Environment Variables
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var recipeList: FetchedResults<RecipeItem>
    
    // MARK: - Observed Object
    @StateObject var viewModel: ContentViewModel
    
    // MARK: - Body
    var body: some View {
        
        switch viewModel.viewState {
        case .loading:
            LoadingView()
        case .successfullyLoaded, .started, .failedToLoad:
            listView
        }
    }
    
    // MARK: - List View
    var listView: some View {
        
        NavigationStack(path: $viewModel.navPath) {
            
            if recipeList.isEmpty {
                EmptyListView()
                    .padding()
            }
            
            GeometryReader { geo in
                
                // MARK: - List
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
                        viewModel.navPath = .init()
                        viewModel.deleteItem(offset: $0,
                                             list: recipeList)
                    }
                    .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
                    
                    if viewModel.searchList(recipeList).isEmpty {
                        Spacer()
                            .listRowBackground(Color.clear)
                    }
                    
                }
                
                // MARK: - UI Modifiers
                .scrollContentBackground(.hidden)
                .background {
                    Image("logo-background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing)
                        .ignoresSafeArea(.all)
                        .opacity(recipeList.isEmpty ? 0 : 0.3)
                }
                .navigationTitle("content.nav.title".localized)
                .navigationBarTitleDisplayMode(.inline)
                
                // MARK: - Toolbar
                .toolbar {
                    ToolbarItem {
                        Button{
                            viewModel.customRecipeSheet = true
                        } label: {
                            Label("content.toolbar.add".localized, systemImage: "plus")
                        }
                    }
                }
                
                // MARK: - URL Open
                .onOpenURL { url in
                    viewModel.onURLOpen(url: url)
                }
                
                // MARK: - Alerts
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
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeView(viewModel: RecipeViewModel(recipe: recipe))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "content.search.prompt".localized)
        .sheet(isPresented: $viewModel.customRecipeSheet) {
            NavigationView {
                RecipeView(viewModel: CreateRecipeViewModel())
            }
        }
        
        
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
