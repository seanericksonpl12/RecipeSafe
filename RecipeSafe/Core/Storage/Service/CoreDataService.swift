//
//  CoreDataService.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/18/25.
//

@preconcurrency import CoreData

protocol CoreDataService<Item>: Sendable, Service {
    
    associatedtype Item: NSManagedObject
    
    var viewContext: NSManagedObjectContext { get }
    var fetch: @Sendable () throws -> [Item] { get }
    var objectWithId: @Sendable (NSManagedObjectID?) -> Item? { get }
    
    init(viewContext: NSManagedObjectContext)
}

extension CoreDataService {
    static var defaultValue: Self { .init(viewContext: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)) }
    static var mock: Self { .init(viewContext: PersistenceController.preview.container.viewContext) }
    
    static func live(viewContext: NSManagedObjectContext) -> Self {
        .init(viewContext: viewContext)
    }
    
    var fetch: @Sendable () throws -> [Item] {
        {
            let request = try self.viewContext.fetch(NSFetchRequest(entityName: Item.description()))
            guard let items = request as? [Item] else { print("casting fail"); throw URLError(.resourceUnavailable) }
            return items
        }
    }
    
    var objectWithId: @Sendable (NSManagedObjectID?) -> Item? {
        { id in
            guard let id else { return nil }
            return viewContext.object(with: id) as? Item
        }
    }
}
