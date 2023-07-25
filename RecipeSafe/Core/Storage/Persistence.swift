//
//  Persistence.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = RecipeItem(context: viewContext)
            newItem.title = "test title"
            newItem.ingredients = ["ingredient test for \(i)", "ingredient 2"]
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RecipeSafe")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveItem(recipe: Recipe) -> RecipeItem? {
        do {
            let request = try container.viewContext.fetch(NSFetchRequest(entityName: "RecipeItem"))
            guard let recipes = request as? [RecipeItem] else { print("casting fail"); return nil }
            
            guard let url = recipe.url else { return nil }
            if recipes.contains(where: { $0.url == url }) { print("recipe is duplicate."); return nil }
            
            let newRecipe = RecipeItem(context: container.viewContext)
            newRecipe.id = recipe.id
            newRecipe.title = recipe.title
            newRecipe.desc = recipe.description
            newRecipe.cookTime = recipe.cookTime
            newRecipe.prepTime = recipe.prepTime
            newRecipe.url = recipe.url
            newRecipe.imageUrl = recipe.img
            newRecipe.ingredients = []
            newRecipe.instructions = []
            recipe.ingredients.forEach { item in
                let i = Ingredient(context: container.viewContext)
                i.value = item
                newRecipe.addToIngredients(i)
            }
            recipe.instructions.forEach { item in
                let i = Instruction(context: container.viewContext)
                i.value = item
                newRecipe.addToInstructions(i)
            }
            
            try container.viewContext.save()
            return newRecipe
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
