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
    
    // MARK: - Properties
    private var viewContext: NSManagedObjectContext
    
    @MainActor static let shared: DataManager = DataManager(viewContext: PersistenceController.shared.container.viewContext)
    
    // MARK: - Inits
    private init(viewContext: NSManagedObjectContext) {
        print("data init")
        self.viewContext = viewContext
    }
    
    func object<T: NSManagedObject>(with id: NSManagedObjectID?) -> T? {
        if let id {
            return self.viewContext.object(with: id) as? T
        } else {
            return nil
        }
    }
    
    func save() {
        do { try self.viewContext.save() }
        catch { print("Failed to Save") }
    }
    
    // MARK: - Recipe Functions
    /// Save a given recipe model to Core Data
    ///
    ///  - Parameters:
    ///     - recipe: The recipe model to save
    ///
    ///  - Returns: The corresponding CoreData RecipeItem object
    func saveItem(_ recipe: Recipe) -> RecipeItem? {
        let newRecipe = RecipeItem(context: self.viewContext)
        newRecipe.id = recipe.id
        newRecipe.title = recipe.title
        newRecipe.desc = recipe.description
        newRecipe.cookTime = recipe.cookTime
        newRecipe.prepTime = recipe.prepTime
        newRecipe.url = recipe.url
        newRecipe.ingredients = []
        newRecipe.instructions = []
        switch recipe.img {
        case .downloaded(let url):
            newRecipe.imageUrl = url
        case .selected(let data):
            newRecipe.photoData = data
        case .none:
            newRecipe.photoData = nil
            newRecipe.imageUrl = nil
        }
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
    
    /// Deletes a given object model from Core Data
    ///
    ///  - Parameters:
    ///     - item: The model to delete
    func deleteItem<T: NSManagedObject>(_ item: T) {
        self.viewContext.delete(item)
        do {
            try self.viewContext.save()
        } catch {
            print(String(describing: error))
        }
    }
    
    /// Updates the data entity corresponding with a recipe model to the values of the recipe model
    ///
    ///  - Parameters:
    ///     - recipe: The recipe model to update
    func updateDataEntity(recipe: inout Recipe) {
        guard let id = recipe.dataEntity, let oldEntity = object(with: id) else { return }
        self.viewContext.delete(oldEntity)
        let entity = saveItem(recipe)
        do {
            try self.viewContext.save()
            recipe.dataEntity = entity?.objectID
        } catch {
            print(String(describing: error))
        }
    }
    
    /// Deletes the data entity of a recipe model
    ///
    ///  - Parameters:
    ///     - recipe: The recipe model to delete the data entity of
    func deleteDataEntity(recipe: Recipe) {
        if let id = recipe.dataEntity, let entity = object(with: id) {
            self.viewContext.delete(entity)
            do {
                try self.viewContext.save()
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    /// Deletes a given object from Core Data
    ///
    ///  - Parameters:
    ///     - offset: Index set of items to delete
    ///     - list: Fetched Results list of objects to apply index set to
    func deleteItem<T: NSManagedObject>(offset: IndexSet, list: FetchedResults<T>) {
        offset.map { list[$0] }
            .forEach {
                if let item = $0 as? GroupItem {
                    if let recipes = item.recipes?.array as? [RecipeItem] {
                        recipes.forEach { $0.group = nil }
                    }
                }
                self.viewContext.delete($0)
            }
        do {
            try self.viewContext.save()
        } catch {
            print(String(describing: error))
        }
    }
    
    /// Check if there already exists a RecipeItem with the data of the given Recipe model
    ///
    ///  - Parameters:
    ///     - recipe: The recipe model to compare against
    ///
    ///  - Returns: The duplicate CoreData RecipeItem object if it exists
    func findDuplicates(_ recipe: Recipe) -> RecipeItem? {
        do {
            let request = try self.viewContext.fetch(NSFetchRequest(entityName: "RecipeItem"))
            guard let recipes = request as? [RecipeItem] else { print("casting fail"); throw URLError(.resourceUnavailable) }
            
            guard let url = recipe.url else { throw URLError(.badURL) }
            return recipes.first { $0.url == url }
            
        } catch {
            print(String(describing: error))
            return nil
        }
    }
    
    
    
    // MARK: - Group Functions
    
    /// Updates the data entity of a given group model
    ///
    ///  - Parameters:
    ///     - group: The group model to update
    func updateDataEntity(group: GroupModel) {
        group.dataEntity.title = group.title
        group.dataEntity.recipes = []
        group.dataEntity.imgUrl = group.imgUrl
        if group.dataEntity.color == 0 {
            group.dataEntity.color = getNewColor()
        }
        group.recipes.forEach { group.dataEntity.addToRecipes($0) }
        do {
            try self.viewContext.save()
        } catch {
            print(String(describing: error))
        }
    }
    
    /// Adds a given recipe to a given groups list of recipes
    ///
    ///  - Parameters:
    ///     - recipe: The recipe model to add to the group
    ///     - group: The group to add the recipe to
    func addToGroup(recipe: Recipe, _ group: GroupItem) {
        if let id = recipe.dataEntity, let data: RecipeItem = object(with: id) {
            group.addToRecipes(data)
            if let recipes = group.recipes?.array as? [RecipeItem] {
                group.imgUrl = recipes.first(where: {$0.imageUrl != nil })?.imageUrl
            }
            do {
                try viewContext.save()
            } catch {
                print(String(describing: error))
                return
            }
        }
    }
    
    /// Creates a new group item with given characteristics
    ///
    ///  - Parameters:
    ///     - title: The name to give the group
    ///     - recipes: Array of recipes to add to the group
    ///     - color: Int16 representation of a color for the group header
    func addGroup(title: String, recipes: [RecipeItem], color: Int16? = nil) {
        let group = GroupItem(context: self.viewContext)
        group.title = title
        group.imgUrl = recipes.first(where: { $0.imageUrl != nil })?.imageUrl
        if let color = color {
            group.color = color
        } else { group.color = getNewColor() }
        recipes.forEach { group.addToRecipes($0) }
        do {
            try viewContext.save()
        } catch {
            print(String(describing: error))
        }
    }
    
    /// Gets an array of a given Core Data object type filtered by a given filter
    ///
    ///  - Parameters:
    ///     - filter: Object to Bool closure to filter results by
    ///
    ///  - Returns: Array of fetched Core Data Objects of the given type
    func getItems<T: NSManagedObject>(filter: ((T) -> Bool)? = nil) -> [T] {
        do {
            let request = try self.viewContext.fetch(NSFetchRequest(entityName: T.description()))
            guard let items = request as? [T] else { print("casting fail"); throw URLError(.resourceUnavailable) }
            if let filter {
                return items.filter(filter)
            }
            return items
        } catch {
            print(String(describing: error))
            return []
        }
    }
    
    /// Gets a new color in Int16 format
    ///
    ///  - Returns: Int16 representation of a color, unused if possible, otherwise random.
    func getNewColor() -> Int16 {
        let groups: [GroupItem] = self.getItems(filter: { _ in true})
        var colors: [Int16 : Bool] = [1:false,2:false,3:false,4:false,5:false,6:false]
        groups.forEach {
            if $0.imgUrl == nil {
                colors[$0.color] = true
            }
        }
        if let newColor = colors.first(where: { $0.value == false })?.key {
            return newColor
        } else { return Int16.random(in: 1..<7) }
    }
}

extension DataManager {
    
    /// Updates Core Data Models if data exists from previous app version
    func appUpdate() {
        if UserDefaults.standard.bool(forKey: "v1.2Update") { return }
        UserDefaults.standard.set(true, forKey: "v1.2Update")
        
        let recipes: [RecipeItem] = self.getItems(filter: {_ in true})
        if !recipes.isEmpty {
            recipes.forEach { recipe in
                if let img = recipe.imageUrl {
                    var components = URLComponents(url: img, resolvingAgainstBaseURL: false)
                    components?.query = ""
                    recipe.imageUrl = components?.url ?? img
                }
            }
        }
        
        let groups: [GroupItem] = self.getItems(filter: {_ in true})
        if !groups.isEmpty {
            groups.forEach { group in
                if group.color == 0 { group.color = self.getNewColor() }
                if group.imgUrl == nil {
                    if let recipes = group.recipes?.array as? [RecipeItem] {
                        group.imgUrl = recipes.first(where: { $0.imageUrl != nil })?.imageUrl
                    }
                }
            }
        }
        
        if groups.isEmpty && recipes.isEmpty { return }
        
        do {
            try self.viewContext.save()
        } catch {
            print(String(describing: error))
        }
    }
}

extension DataManager {
    
    func isInShoppingList(_ recipe: RecipeItem?) -> Bool {
        !(recipe?.shoppinglistitems?.allObjects.isEmpty ?? true)
    }
    
    func toggleShoppingList(recipe: RecipeItem?) {
        isInShoppingList(recipe) ? removeFromShoppingList(recipe: recipe) : addToShoppingList(recipe: recipe)
    }
    
    func addToShoppingList(recipe: RecipeItem?) {
        guard let recipe else { return }
        
        if let ingredients = recipe.ingredients?.array as? [Ingredient] {
            for ingredient in ingredients {
                if let text = ingredient.value {
                    let newItem = ShoppingListItem(context: self.viewContext)
                    newItem.recipe = recipe
                    newItem.value = text
                    recipe.addToShoppinglistitems(newItem)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error Saving shopping list")
            }
        }
    }
    
    func removeFromShoppingList(recipe: RecipeItem?) {
        guard let recipe else { return }
        
        if let items = recipe.shoppinglistitems?.allObjects as? [ShoppingListItem] {
            for item in items {
                self.viewContext.delete(item)
            }
        }
        recipe.shoppinglistitems = nil
        do {
            try self.viewContext.save()
        } catch {
            print("Error Removing items from shopping list")
        }
    }
    
    func removeFromShoppingList(shoppingListItem: ShoppingListItem?) {
        guard let shoppingListItem else { return }
        self.viewContext.delete(shoppingListItem)
        do {
            try self.viewContext.save()
        } catch {
            print("Error Removing items from shopping list")
        }
    }
    
    func addShoppingListItem(_ text: String? = nil, index: Int16) {
        let item = ShoppingListItem(context: self.viewContext)
        item.value = text
        item.index = index
        do {
            try self.viewContext.save()
        } catch {
            print("Error Removing items from shopping list")
        }
    }
    
    func clearShoppingList() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingListItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch let error as NSError {
            print("error!: \(error)")
        }
    }
}
