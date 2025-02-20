//
//  LaunchView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/18/25.
//

import SwiftUI
import Injector

struct LaunchView: View {
    
    @Environment(\.services.network.fetchAppConfig) var fetchAppConfig
    
    var body: some View {
        if AppConfig.shared.state == .loading  {
            LaunchScreen()
                .ignoresSafeArea()
                .task { await fetchAppConfig() }
        } else {
            ContentView()
        }
    }
}
