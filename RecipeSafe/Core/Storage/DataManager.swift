//
//  DataManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/3/23.
//

import Foundation
import CoreData
import SwiftUI

class DataManager {
    
    private var viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    convenience init() {
        self.init(viewContext: PersistenceController.shared.container.viewContext)
    }
    
    
    // MARK: - Recipe Functions
    func saveItem(_ recipe: Recipe) -> RecipeItem? {
        let newRecipe = RecipeItem(context: self.viewContext)
        newRecipe.id = recipe.id
        newRecipe.title = recipe.title
        newRecipe.desc = recipe.description
        newRecipe.cookTime = recipe.cookTime
        newRecipe.prepTime = recipe.prepTime
        newRecipe.url = recipe.url
        newRecipe.imageUrl = recipe.img
        newRecipe.photoData = recipe.photoData
        newRecipe.ingredients = []
        newRecipe.instructions = []
        recipe.ingredients.forEach { item in
            let i = Ingredient(context: self.viewContext)
            i.value = item
            newRecipe.addToIngredients(i)
        }
        recipe.instructions.forEach { item in
            let i = Instruction(context: self.viewContext)
            i.value = item
            newRecipe.addToInstructions(i)
        }
        do {
            try self.viewContext.save()
        } catch {
            print(String(describing: error))
        }
        return newRecipe
    }
    
    func deleteItem(_ item: RecipeItem) {
        self.viewContext.delete(item)
        do {
            try self.viewContext.save()
        } catch {
            print(String(describing: error))
        }
    }
    
    func updateDataEntity(recipe: Recipe) {
        recipe.dataEntity?.title = recipe.title
        recipe.dataEntity?.desc = recipe.description
        recipe.dataEntity?.photoData = recipe.photoData
        recipe.dataEntity?.ingredients = []
        recipe.dataEntity?.instructions = []
        recipe.ingredients.forEach {
            let i = Ingredient(context: self.viewContext)
            i.value = $0
            recipe.dataEntity?.addToIngredients(i)
        }
        recipe.instructions.forEach {
            let i = Instruction(context: self.viewContext)
            i.value = $0
            recipe.dataEntity?.addToInstructions(i)
        }
        do {
            try self.viewContext.save()
        } catch {
            print(String(describing: error))
        }
    }
    
    func deleteDataEntity(recipe: Recipe) {
        if let entity = recipe.dataEntity {
            self.viewContext.delete(entity)
            do {
                try self.viewContext.save()
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func deleteItem(offset: IndexSet, list: FetchedResults<RecipeItem>) {
        offset.map { list[$0] }
            .forEach {
                self.viewContext.delete($0)
            }
    }
    
    func findDuplicates(_ recipe: Recipe) -> RecipeItem? {
        do {
            let request = try self.viewContext.fetch(NSFetchRequest(entityName: "RecipeItem"))
            guard let recipes = request as? [RecipeItem] else { print("casting fail"); throw URLError(.resourceUnavailable) }
            
            guard let url = recipe.url else { throw URLError(.badURL) }
            return recipes.first { $0.url == url }
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
