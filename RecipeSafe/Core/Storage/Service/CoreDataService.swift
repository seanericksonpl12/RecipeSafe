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
    var saveContext: @Sendable () throws -> Void { get }
    var deleteItem: @Sendable (Item) throws -> Void { get }
    var fetch: @Sendable () throws -> [Item] { get }
    var objectWithId: @Sendable (NSManagedObjectID?) -> Item? { get }
    
    init(viewContext: NSManagedObjectContext)
}

extension CoreDataService {
    static var defaultValue: Self { .init(viewContext: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)) }
    static var mock: Self { .init(viewContext: PersistenceController.preview.container.viewContext) }
    static var live: Self { .init(viewContext: PersistenceController.shared.container.viewContext) }
    
    var saveContext: @Sendable () throws -> Void {
        { try self.viewContext.save() }
    }
    
    var deleteItem: @Sendable (Item) throws -> Void {
        {
            self.viewContext.delete($0)
            try self.viewContext.save()
        }
    }
    
    var fetch: @Sendable () throws -> [Item] {
        { return try self.viewContext.fetchItems() }
    }
    
    var objectWithId: @Sendable (NSManagedObjectID?) -> Item? {
        { id in
            guard let id else { return nil }
            return viewContext.object(with: id) as? Item
        }
    }
}
