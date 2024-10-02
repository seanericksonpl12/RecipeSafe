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
            Group {
                if viewModel.appConfig.state == .loading  {
                    LaunchScreen()
                        .ignoresSafeArea()
                } else {
                    switch viewModel.viewState {
                    case .started, .successfullyLoaded, .failedToLoad:
                        ContentView()
                            .environmentObject(viewModel)
                    case .loading:
                        LoadingView()
                    }
                }
            }.animation(.smooth(duration: 0.5), value: viewModel.appConfig.state)
        }
    }
}
