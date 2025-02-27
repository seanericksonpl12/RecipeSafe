//
//  RecipeSafeApp.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI

@main
struct RecipeSafeApp: App {
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .injectServices()
        }
    }
}
