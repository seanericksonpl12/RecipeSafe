//
//  SearchResultsView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/15/24.
//

import SwiftUI

struct SearchView: View {
    
    @StateObject var viewModel: SearchViewModel
    
    @State var size: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack {
                    SearchTextField(
                        text: $viewModel.text,
                        isFocusing: $viewModel.isSearchFocused,
                        placeholder: "Search",
                        delegate: viewModel
                    )
                    .padding()
                    
                    if viewModel.isSearchFocused {
                        suggestions
                    } else {
                        switch viewModel.state {
                        case .waiting, .failed:
                            waiting
                        case .backgroundRunning, .loaded:
                            recipeView
                        case .loading:
                            LoadingView()
                        }
                        Spacer()
                    }
                }
                .applyAppBackground(proxy: geo)
                .navigationTitle("search.nav.title".localized)
                .onChange(of: geo.size) { old, new in
                    self.size = new
                }
            }
            .sheet(isPresented: $viewModel.presentHistory) {
                historyView
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    var waiting: some View {
        ScrollView {
            HStack {
                Text("Suggestions")
                    .font(.title3)
                    .padding(.leading)
                Spacer()
            }
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], alignment: .center, spacing: 0) {
                ForEach(Array(viewModel.suggestedRecipes.enumerated()), id: \.element) { i, recipe in
                    SuggestionTile(title: recipe.title, size: size, img: URL(string: recipe.link), color: Int16(i + 1)) {
                        viewModel.suggestionTapped(text: recipe.title)
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 0, trailing: 10))
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
                            // RecipeView(viewModel: RecipeViewModel(recipe: viewModel.checkIfSaved(recipe: recipe), screen: .search))
                            RecipeView(recipe: viewModel.checkIfSaved(recipe: recipe), screen: .search)
                        } label: {
                            SearchRecipeView(recipe: recipe)
                        }
                    }
                    .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    var suggestions: some View {
        ScrollView {
            if viewModel.text.isEmpty && !viewModel.recentSearches.recentArray.isEmpty {
                recentSearchView
            } else if viewModel.text.isEmpty && viewModel.recentSearches.recentArray.isEmpty {
                    EmptyListView(description: "Try making some new searches!")
            } else {
                    SearchList(viewModel.filteredAutoFillValues, text: $viewModel.text) { item in
                        Text(item)
                    } action: { value in
                        viewModel.suggestionTapped(text: value)
                    }
            }
        }
    }
    
    @ViewBuilder
    var recentSearchView: some View {
        HStack {
            Text("Recent Searches")
                .font(.title3)
            Spacer()
            
            Button {
                withAnimation {
                    viewModel.seeAllTapped()
                }
            } label: {
                Text("See All")
            }
        }
        .font(.callout)
        .padding([.leading, .trailing, .bottom])
        
        SearchList(viewModel.recentSearches.recentArray, text: $viewModel.text) { item in
            Text(item)
        } action: { value in
            viewModel.suggestionTapped(text: value)
        }
    }
    
    @ViewBuilder
    var historyView: some View {
        
            HStack {
                Text("History")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                
                Button {
                    withAnimation {
                        viewModel.clearHistory()
                    }
                } label: {
                    Image(systemName: "trash")
                }
            }
            
            .padding()
        ScrollView {
            if viewModel.recentSearches.fullArray.isEmpty {
                EmptyListView(description: "Try making some new searches!")
                    .padding()
            } else {
                SearchList(viewModel.recentSearches.fullArray, text: $viewModel.text) { item in
                    Text(item)
                } action: { value in
                    viewModel.suggestionTapped(text: value)
                    viewModel.dismissHistoryView()
                }
            }
        }
    }
}
