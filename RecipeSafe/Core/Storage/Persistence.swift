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
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = RecipeItem(context: viewContext)
            newItem.title = "Recipe Number \(i)"
            let i1 = Ingredient(context: viewContext)
            i1.value = "ingredient 1"
            let i2 = Ingredient(context: viewContext)
            i2.value = "ingredient 2"
            let in1 = Instruction(context: viewContext)
            in1.value = "step 1"
            let in2 = Instruction(context: viewContext)
            in2.value = "step 2"
            newItem.desc = "Description of recipe \(i)"
            newItem.addToIngredients(i1)
            newItem.addToIngredients(i2)
            newItem.addToInstructions(in1)
            newItem.addToInstructions(in2)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
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
                print(String(describing: error))
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
