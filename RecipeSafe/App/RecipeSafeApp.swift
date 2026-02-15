//
//  RecipeSafeApp.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct RecipeSafeApp: App {
    
    var body: some Scene {
        WindowGroup {
            LaunchView(store: Store(initialState: LaunchReducer.LaunchState()) {
                LaunchReducer()
            })
        }
    }
}
