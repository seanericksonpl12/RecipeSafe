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
    
    // MARK: - Inits
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    convenience init() {
        self.init(viewContext: PersistenceController.shared.container.viewContext)
    }
}
    
// MARK: - Recipe Functions
extension DataManager {
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
    
    func deleteItem<T: NSManagedObject>(_ item: T) {
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
        recipe.dataEntity?.prepTime = recipe.prepTime
        recipe.dataEntity?.cookTime = recipe.cookTime
        recipe.dataEntity?.ingredients = []
        recipe.dataEntity?.instructions = []
        if case .selected(let data) = recipe.img {
            recipe.dataEntity?.photoData = data
        }
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
}

// MARK: - Group Functions
extension DataManager {
    
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
    
    func addToGroup(recipe: Recipe, _ group: GroupItem) {
        if let data = recipe.dataEntity {
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
    
    func getItems<T: NSManagedObject>(filter: ((T) -> Bool)) -> [T] {
        do {
            let request = try self.viewContext.fetch(NSFetchRequest(entityName: T.description()))
            guard let items = request as? [T] else { print("casting fail"); throw URLError(.resourceUnavailable) }
            return items.filter(filter)
        } catch {
            print(String(describing: error))
            return []
        }
    }
    
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
