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
            LaunchView()
                .injectServices()
                .environmentObject(viewModel)
                .animation(.smooth(duration: 0.5), value: viewModel.appConfig.state)
                .environment(\.managedObjectContext, AppEnvironment.shouldMock ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext)
        }
    }
}
