//
//  CoreDataExtensions.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/20/25.
//

import CoreData

extension NSManagedObjectContext {
    
    func fetchItems<T: NSManagedObject>() throws -> [T] {
        let request = try self.fetch(NSFetchRequest(entityName: T.description()))
        guard let items = request as? [T] else { print("casting fail"); throw URLError(.resourceUnavailable) }
        return items
    }
}
