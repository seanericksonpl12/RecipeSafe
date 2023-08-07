//
//  Persistence.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import CoreData
import SwiftUI

struct PersistenceController {
    // MARK: - Instances
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = RecipeItem(context: viewContext)
            newItem.title = "Recipe"
            let i1 = Ingredient(context: viewContext)
            let i2 = Ingredient(context: viewContext)
            let in1 = Instruction(context: viewContext)
            let in2 = Instruction(context: viewContext)
            newItem.desc = "Description"
            newItem.ingredients = [i1, i2]
            newItem.instructions = [in1, in2]
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    // MARK: - Container
    let container: NSPersistentContainer
    
    // MARK: - Init
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RecipeSafe")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
