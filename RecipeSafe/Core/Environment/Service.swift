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
    static func live(_ dependencies: ServiceDependencies) -> Self
    static var mock: Self { get }
    static var defaultValue: Self { get }
}

enum Services {
    static func resolve<T: Service>(_ service: T.Type = T.self, serviceDependencies: ServiceDependencies) -> T {
        AppEnvironment.shouldMock ? T.mock : T.live(serviceDependencies)
    }
    
    static func resolveViewContext() -> NSManagedObjectContext {
        AppEnvironment.shouldMock ? PersistenceController.preview.container.viewContext : PersistenceController.shared.container.viewContext
    }
    
    static func resolveHttpClient(session: URLSession) -> NetworkClient {
        AppEnvironment.shouldMock ? HttpClient(session: session) : MockHttpClient(session: session)
    }
}

struct ServiceValues: Sendable {
    var network: NetworkService
    var recipeData: RecipeDataService
    var groupData: GroupDataService
    var shoppingListData: ShoppingListDataService
    var update: UpdateService
}

struct ServiceDependencies: @unchecked Sendable {
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.networkClient = Services.resolveHttpClient(session: session)
        self.viewContext = Services.resolveViewContext()
    }
    var networkClient: NetworkClient
    var viewContext: NSManagedObjectContext
}

extension EnvironmentValues {
    @Entry var services = ServiceValues(
        network: .defaultValue,
        recipeData: .defaultValue,
        groupData: .defaultValue,
        shoppingListData: .defaultValue,
        update: .defaultValue
    )
    
    @Entry var serviceDependencies = ServiceDependencies(
        session: URLSession.shared
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
    
    let dependencies: ServiceDependencies
    
    private var services: ServiceValues {
        .init(
            network: Services.resolve(serviceDependencies: dependencies),
            recipeData: Services.resolve(serviceDependencies: dependencies),
            groupData: Services.resolve(serviceDependencies: dependencies),
            shoppingListData: Services.resolve(serviceDependencies: dependencies),
            update: Services.resolve(serviceDependencies: dependencies)
        )
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.services, services)
            .environment(\.managedObjectContext, dependencies.viewContext)
    }
}

extension View {
    func injectServices(_ dependencies: ServiceDependencies) -> some View {
        self.modifier(InjectServices(dependencies: dependencies))
    }
}
