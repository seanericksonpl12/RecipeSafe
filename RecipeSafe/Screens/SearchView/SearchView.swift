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
            GeometryReader { geo in
                SearchResultsView(viewModel: viewModel, geo: geo)
                    .searchable(text: $viewModel.text, placement: .navigationBarDrawer(displayMode: .always))
                    .onSubmit(of: .search) {
                        viewModel.searchSubmitted()
                    }
                
                    .searchSuggestions {
                        if viewModel.text.isEmpty && !viewModel.seeAllRecentSearches {
                            HStack {
                                Text("Recent Searches")
                                Spacer()
                                Button {
                                    viewModel.seeAllTapped()
                                } label: {
                                    Text("See All")
                                }
                            }
                            .font(.callout)
                            
                            ForEach(viewModel.recentSearches.recentArray.toIdentifiable(), id: \.id) { item in
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text(item.value)
                                    Spacer()
                                }
                            }
                            
                            //                            HStack {
                            //                                Text("Find nearby")
                            //                                Spacer()
                            //                                Button(action: {}) {
                            //                                    Text("See all")
                            //                                }
                            //                            }
                            //                            .padding(.top)
                            //                            .font(.callout)
                        } else if viewModel.seeAllRecentSearches {
                            ForEach(viewModel.recentSearches.fullArray.toIdentifiable()) { element in
                                VStack(alignment: .leading) {
                                    Text(element.value)
                                }
                                .searchCompletion(element.value)
                            }
                        } else if viewModel.filteredAutoFillValues.isEmpty {
                            VStack(alignment: .leading) {
                                Text("")
                            }
                        } else {
                            ForEach(viewModel.filteredAutoFillValues, id: \.hashValue) { completion in
                                VStack(alignment: .leading) {
                                    Text(completion)
                                }
                                .searchCompletion(completion)
                            }
                        }
                    }
                    .background {
                        Image("logo-background")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing)
                            .ignoresSafeArea(.all)
                            .opacity( 0.15)
                    }
                    .navigationTitle("search.nav.title".localized)
            }
        }
    }
}
