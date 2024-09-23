//
//  RecipeSafeApp.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppReducer {
    struct State {
        var searchState = SearchReducer.State(textFieldState: SearchTextFieldReducer.State())
    }
    
    enum Action {
        case searchAction(SearchReducer.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.searchState, action: \.searchAction) {
            SearchReducer()
        }
    }
}

@main
struct RecipeSafeApp: App {
    let store: StoreOf<AppReducer> = Store(initialState: AppReducer.State()) {
        AppReducer()
    }
    // MARK: - ViewModel
    @StateObject private var viewModel = AppViewModel()

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            switch viewModel.viewState {
            case .started, .successfullyLoaded, .failedToLoad:
                tabView
            case .loading:
                LoadingView()
            }
        }
    }
    
    // MARK: - Tab View
    var tabView: some View {
        TabView(selection: $viewModel.tabSelection) {
            ContentView(viewModel: viewModel.contentViewModel)
                .environment(\.managedObjectContext, viewModel.persistenceController.container.viewContext)
                .tabItem {
                    Label("app.all".localized, systemImage: "line.3.horizontal")
                }
                .tag(1)
            GroupGridView(viewModel: viewModel.groupViewModel)
                .environment(\.managedObjectContext, viewModel.persistenceController.container.viewContext)
                .tabItem {
                    Label("app.group".localized, systemImage: "circlebadge.2")
                }
                .tag(2)
            TCASearchView(store: store.scope(state: \.searchState, action: \.searchAction))
                .tabItem {
                    Label("app.search".localized, systemImage: "globe")
                }
                .tag(3)
//            SearchView(viewModel: SearchViewModel())
//                .tabItem {
//                    Label("app.search".localized, systemImage: "globe")
//                }
//                .tag(3)
        }
        .onOpenURL { url in
            self.viewModel.onURLOpen(url: url)
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
        .popover(isPresented: $viewModel.launchTutorial) {
            TutorialView(viewModel: TutorialViewModel(dismiss: $viewModel.launchTutorial))
        }
        .onAppear {
            let tabBar = UITabBarAppearance()
            tabBar.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBar
        }
    }
}
