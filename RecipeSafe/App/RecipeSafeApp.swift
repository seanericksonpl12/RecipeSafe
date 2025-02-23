//
//  RecipeSafeApp.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI

@main
struct RecipeSafeApp: App {
    
    let context = AppEnvironment.shouldMock ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
    let session = URLSession(configuration: .default)
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .injectServices(viewContext: context, client: HttpClient(session: session))
        }
    }
}
