//
//  SearchResultsView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/15/24.
//

import SwiftUI

struct SearchResultsView: View {
    
    @StateObject var viewModel: SearchViewModel
    @Environment(\.dismissSearch) var dismissSearch
    @Environment(\.isSearching) var isSearching
    
    var geo: GeometryProxy
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .waiting, .failed:
                waiting(geo: geo)
            case .backgroundRunning, .loaded:
                recipeView
            case .loading:
                LoadingView()
            }
            Spacer()
        }
        .onAppear {
            viewModel.dismissSearch = { dismissSearch() }
        }
        .onChange(of: isSearching) {
            viewModel.isSearching($0)
        }
    }
    
    var columns: [GridItem] = [
        GridItem(.fixed(100)),
        GridItem(.fixed(100))
    ]
    
    func waiting(geo: GeometryProxy) -> some View {
        GeometryReader { geo in
            ScrollView {
                HStack {
                    Text("Suggestions")
                        .font(.title2)
                        .padding(.leading)
                    Button {
                        print("refreshing")
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .padding(.leading)
                    Spacer()
                }
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], alignment: .center, spacing: 20) {
                    ForEach(Array(viewModel.suggestedRecipes.enumerated()), id: \.element) { i, recipe in
                        SuggestionTile(title: recipe.title, geo: geo, img: URL(string: recipe.link), color: Int16(i + 1)) {
                            viewModel.suggestionTapped(text: recipe.title)
                        }
                    }
                    //.padding()
                }
                .padding(EdgeInsets(top: 8, leading: 10, bottom: 0, trailing: 10))
            }
        }
    }
    
    @ViewBuilder
    var recipeView: some View {
        if viewModel.results.isEmpty {
            Color.clear
        } else {
            List {
                Section {
                    ForEach(viewModel.results) { recipe in
                        NavigationLink {
                            RecipeView(viewModel: RecipeViewModel(recipe: viewModel.checkIfSaved(recipe: recipe), screen: .search))
                        } label: {
                            SearchRecipeView(recipe: recipe)
                        }
                    }
                    .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
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
            .scrollContentBackground(.hidden)
        }
    }
    
    var failedView: some View {
        Text("Whoops, something went wrong")
            .padding()
    }
}
