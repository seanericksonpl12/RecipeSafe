//
//  SearchView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/3/24.
//

import SwiftUI

struct SearchView: View {
    
    @StateObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                searchBar
                switch viewModel.state {
                case .backgroundRunning, .loaded, .waiting:
                    recipeView
                case .failed:
                    failedView
                case .loading:
                    LoadingView()
                }
            }
        }
    }
    
    var searchBar: some View {
        SearchTextField(text: $viewModel.text,
                        isLoading: $viewModel.isLoading,
                        placeholder: "search",
                        delegate: viewModel)
            .padding()
    }
    
    var recipeView: some View {
        List {
            Section {
                ForEach(viewModel.results) { recipe in
                    NavigationLink {
                        RecipeView(viewModel: RecipeViewModel(recipe: recipe))
                    } label: {
                        SearchRecipeView(recipe: recipe)
                    }
                }
            }
            if viewModel.state == .loaded {
                Section {
                    Button {
                        print("load more")
                    } label: {
                        Text("Load More")
                    }
                }
            }
        }
    }
    
    var failedView: some View {
        Text("Whoops, something went wrong")
            .padding()
    }
}
