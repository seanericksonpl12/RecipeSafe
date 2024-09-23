//
//  TCASearchView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/21/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct TCASearchView: View {
    
    @Perception.Bindable var store: StoreOf<SearchReducer>
    
    var body: some View {
            GeometryReader { proxy in
                WithPerceptionTracking {
                VStack {
                    TCASearchTextField(store: store.scope(state: \.textFieldState, action: \.searchTextField))
                        .padding()
                    switch store.screenState {
                    case .recipes:
                        recipeView
                    case .autocomplete:
                        autocompleteView
                    case .recentResults:
                        recentSearchesView
                    case .history:
                        historyView
                    case .suggestions:
                        suggestionsView(size: proxy.size)
                    case .failure:
                        failureView
                    }
                }
                .applyAppBackground(proxy: proxy)
                .navigationTitle("search.nav.title".localized)
            }
        }
            .onAppear {
                store.send(.viewDidAppear)
            }
    }
}

// MARK: - Views
extension TCASearchView {
    
    // MARK: - Recipe View
    var recipeView: some View {
        Text("Recipes")
            .padding()
    }
    
    // MARK: - Suggestions View
    func suggestionsView(size: CGSize) -> some View {
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
                ForEach(Array(store.suggestedRecipes.enumerated()), id: \.element) { i, recipe in
                    SuggestionTile(title: recipe.title, size: size, img: URL(string: recipe.link), color: Int16(i + 1)) {
                        store.send(.searchItemTapped(recipe.title))
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 0, trailing: 10))
        }
    }
    
    // MARK: - Recent Searches View
    var recentSearchesView: some View {
        VStack {
            HStack {
                Text("Recent Searches")
                    .font(.title3)
                Spacer()
                
                Button {
                    store.send(.seeAllSearchesTapped, animation: .smooth)
                } label: {
                    Text("See All")
                }
            }
            .font(.callout)
            .padding([.leading, .trailing, .bottom])
            
            SearchList(store.recentSearches.recentArray, text: $store.textFieldState.text.sending(\.searchTextField.textChanged)) { item in
                Text(item)
            } action: { value in
                store.send(.searchItemTapped(value))
            }
        }
    }
    
    // MARK: - Autocomplete View
    var autocompleteView: some View {
        Text("Autocomplete")
            .padding()
    }
    
    // MARK: - History View
    var historyView: some View {
        Text("All History")
            .padding()
    }
    
    // MARK: - Failure View
    var failureView: some View {
        Text("Whoops, Something Went Wrong")
            .padding()
    }
}

#Preview {
    TCASearchView(
        store: Store(initialState: SearchReducer.State(textFieldState: SearchTextFieldReducer.State())) {
            SearchReducer()
                ._printChanges()
        }
    )
}
