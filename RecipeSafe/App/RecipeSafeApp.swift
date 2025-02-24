//
//  RecipeSafeApp.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI

@main
struct RecipeSafeApp: App {
    
    let session: URLSession = URLSession(configuration: .default)
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .injectServices(ServiceDependencies(session: session))
        }
    }
}
