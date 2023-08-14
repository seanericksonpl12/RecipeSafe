//
//  RecipeSafeApp.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI

@main
struct RecipeSafeApp: App {
    @State private var tabSelection: Int = 1
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView(selection: $tabSelection) {
                ContentView(viewModel: ContentViewModel())
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("app.all".localized, systemImage: "circle.fill")
                    }
                    .tag(1)
                GroupGridView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("app.group".localized, systemImage: "circle")
                    }
                    .tag(2)
            }
            .onAppear {
                let tabBar = UITabBarAppearance()
                tabBar.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBar
            }
            .onOpenURL { _ in
                self.tabSelection = 1
            }
        }
    }
}
