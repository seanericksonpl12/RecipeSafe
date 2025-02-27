//
//  Service.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 10/3/24.
//

import Foundation
import SwiftUI
import CoreData

protocol Service {
    static var defaultValue: Self { get }
    static var live: Self { get }
    static var mock: Self { get }
}

enum Services {
    static func resolve<T: Service>(_ service: T.Type = T.self) -> T {
        AppEnvironment.shouldMock ? T.mock : T.live
    }
    
    static func resolveViewContext() -> NSManagedObjectContext {
        AppEnvironment.shouldMock ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
    }
    
    static func resolveHttpClient(session: URLSession) -> NetworkClient {
        AppEnvironment.shouldMock ? MockHttpClient(session: session) : HttpClient(session: session)
    }
}

struct ServiceValues: Sendable, Injectable {
    static var defaultValue: Self {
        .init(
            network: .defaultValue,
            recipeData: .defaultValue,
            groupData: .defaultValue,
            shoppingListData: .defaultValue,
            update: .defaultValue,
            analytics: .defaultValue
        )
    }
    
    var network: NetworkService
    var recipeData: RecipeDataService
    var groupData: GroupDataService
    var shoppingListData: ShoppingListDataService
    var update: UpdateService
    var analytics: AnalyticsService
}

private struct InjectServices: ViewModifier {
    
    private var services: ServiceValues {
        .init(
            network: Services.resolve(),
            recipeData: Services.resolve(),
            groupData: Services.resolve(),
            shoppingListData: Services.resolve(),
            update: Services.resolve(),
            analytics: Services.resolve()
        )
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.services, services)
            .environment(\.managedObjectContext, Services.resolveViewContext())
    }
}

extension View {
    func injectServices() -> some View {
        self.modifier(InjectServices())
    }
}
