//
//  RecipeSafeApp.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI

@main
struct RecipeSafeApp: App {
    
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
        .onAppear {
            let tabBar = UITabBarAppearance()
            tabBar.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBar
        }
    }
}
