//
//  LaunchView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/18/25.
//

import SwiftUI

struct LaunchView: View {
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
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
        }
        .animation(.smooth(duration: 0.5), value: viewModel.appConfig.state)
    }
}
