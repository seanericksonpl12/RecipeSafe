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
            AllRecipesView(viewModel: viewModel.allRecipesViewModel)
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
            if viewModel.appConfig.searchAvailable {
                SearchView(viewModel: SearchViewModel())
                    .tabItem {
                        Label("app.search".localized, systemImage: "globe")
                    }
                    .tag(3)
            }
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

#Preview {
    ContentView()
}
