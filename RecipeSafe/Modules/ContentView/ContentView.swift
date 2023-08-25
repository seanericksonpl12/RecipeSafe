//
//  ContentView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var recipeList: FetchedResults<RecipeItem>
    
    // MARK: - ViewModel
    @StateObject var viewModel: ContentViewModel
    
    // MARK: - Body
    var body: some View {
        
        NavigationStack(path: $viewModel.navPath) {
            
            if recipeList.isEmpty {
                EmptyListView(description: "empty.desc.1".localized)
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
                        .opacity(recipeList.isEmpty ? 0 : 0.15)
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
                                .frame(width: 40, height: 40)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
            
            // MARK: - Navigation
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
