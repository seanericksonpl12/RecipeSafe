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
    static func live(viewContext: NSManagedObjectContext, client: NetworkClient) -> Self
    static var mock: Self { get }
    
    static var defaultValue: Self { get }
}

enum Services {
    static func resolve<T: Service>(_ service: T.Type = T.self, viewContext: NSManagedObjectContext, client: NetworkClient) -> T {
        AppEnvironment.shouldMock ? T.mock : T.live(viewContext: viewContext, client: client)
    }
}

struct ServiceValues: Sendable {
    var network: NetworkService
    var recipeData: RecipeDataService
    var groupData: GroupDataService
    var shoppingListData: ShoppingListDataService
    var update: UpdateService
}

extension EnvironmentValues {
    @Entry var services = ServiceValues(
        network: .defaultValue,
        recipeData: .defaultValue,
        groupData: .defaultValue,
        shoppingListData: .defaultValue,
        update: .defaultValue
    )
    
    @Entry var toolbarActions = ToolbarActions(
        save: {},
        delete: {},
        cancel: {},
        option1: {},
        option2: {}
    )
}

private struct InjectServices: ViewModifier {
    
    let viewContext: NSManagedObjectContext
    let client: NetworkClient
    
    private var services: ServiceValues {
        .init(
            network: Services.resolve(viewContext: viewContext, client: client),
            recipeData: Services.resolve(viewContext: viewContext, client: client),
            groupData: Services.resolve(viewContext: viewContext, client: client),
            shoppingListData: Services.resolve(viewContext: viewContext, client: client),
            update: Services.resolve(viewContext: viewContext, client: client)
        )
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.services, services)
            .environment(\.managedObjectContext, viewContext)
    }
}

extension View {
    func injectServices(viewContext: NSManagedObjectContext, client: NetworkClient) -> some View {
        self.modifier(InjectServices(viewContext: viewContext, client: client))
    }
}
