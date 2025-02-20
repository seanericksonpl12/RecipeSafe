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
    static func live(viewContext: NSManagedObjectContext) -> Self
    static var mock: Self { get }
    
    static var defaultValue: Self { get }
}

enum Services {
    static func resolve<T: Service>(_ service: T.Type = T.self, viewContext: NSManagedObjectContext) -> T {
        AppEnvironment.shouldMock ? T.mock : T.live(viewContext: viewContext)
    }
}

struct ServiceValues: Sendable {
    var network: NetworkService
    var recipeData: RecipeDataService
    var groupData: GroupDataService
    var shoppingListData: ShoppingListDataService
}

private struct InjectServices: ViewModifier {
    
    @Environment(\.managedObjectContext) var viewContext
    
    private var services: ServiceValues {
        .init(
            network: Services.resolve(viewContext: viewContext),
            recipeData: Services.resolve(viewContext: viewContext),
            groupData: Services.resolve(viewContext: viewContext),
            shoppingListData: Services.resolve(viewContext: viewContext)
        )
    }
    
    func body(content: Content) -> some View {
        content.environment(\.services, services)
    }
}

extension View {
    func injectServices() -> some View {
        self.modifier(InjectServices())
    }
}
