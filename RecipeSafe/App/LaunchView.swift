//
//  LaunchView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/18/25.
//

import SwiftUI

struct LaunchView: View {
    
    @Environment(\.services.network) var network
    @State var isLoaded = false
    @State var appConfig: AppConfig = .defaultValue
    
    var body: some View {
        if !isLoaded  {
            LaunchScreen()
                .ignoresSafeArea()
                .task { await setup() }
        } else {
            ContentView()
                .addKeyboardToEnvironment()
                .environment(\.appConfig, self.appConfig)
        }
    }
    
    func setup() async {
        defer { withAnimation { self.isLoaded = true } }
        do {
            self.appConfig = try await network.fetchAppConfig()
            
            if appConfig.appHealth.needsAttestation {
                try await network.attestApp()
            }
        } catch {
            Logger.log("Failed to load app config with error: \(error)")
        }
    }
}
