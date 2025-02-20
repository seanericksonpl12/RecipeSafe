//
//  ContentView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/30/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        TabView(selection: $viewModel.tabSelection) {
            AllRecipesView(navPath: viewModel.allRecipesNavPath)
                .tabItem {
                    Label("app.all".localized, systemImage: "line.3.horizontal")
                }
                .tag(1)
            GroupGridView(navPath: $viewModel.groupNavPath, newRecipe: $viewModel.newRecipe, newRecipeSwitch: $viewModel.newRecipeSwitch)
                .tabItem {
                    Label("app.group".localized, systemImage: "circlebadge.2")
                }
                .tag(2)
            ShoppingListView()
                .tabItem {
                    Label("app.shopping".localized, systemImage: "list.clipboard")
                }
                .tag(3)
            
            if viewModel.appConfig.searchAvailable {
                SearchView(viewModel: SearchViewModel())
                    .tabItem {
                        Label("app.search".localized, systemImage: "globe")
                    }
                    .tag(4)
            }
        }
        .onOpenURL { url in
            print("opening...")
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
          //  dataManager.getShoppingList()
        }
    }
}

//#Preview {
//    ContentView()
//}
