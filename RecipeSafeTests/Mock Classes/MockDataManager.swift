//
//  MockDataManager.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/4/23.
//

import Foundation
import XCTest
@testable import RecipeSafe
import CoreData

class MockDataManager: DataManager {
    
    var viewContext: NSManagedObjectContext
    var saveItemExpectation: XCTestExpectation?
    var deleteItemExpectation: XCTestExpectation?
    var findDuplicate: Bool = false
    var recipe: Recipe?
    var group: GroupItem?
    var recipeToDelete: RecipeItem?
    var groupToDelete: GroupItem?
    
    override init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        super.init(viewContext: viewContext)
    }
    
    override func saveItem(_ recipe: Recipe) -> RecipeItem? {
        self.recipe = recipe
        let newRecipe = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: self.viewContext) as! RecipeItem
        self.saveItemExpectation?.fulfill()
        return newRecipe
    }
    
    override func findDuplicates(_ recipe: Recipe) -> RecipeItem? {
        if findDuplicate {
            self.recipe = recipe
            let newRecipe = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: self.viewContext) as! RecipeItem
            newRecipe.title = "Test Duplicate"
            return newRecipe
        } else {
            return nil
        }
    }
    
    override func deleteItem<T>(_ item: T) where T : NSManagedObject {
        if let i = item as? RecipeItem {
            self.recipeToDelete = i
        } else if let g = item as? GroupItem {
            self.groupToDelete = g
        }
        deleteItemExpectation?.fulfill()
    }
    
        // MARK: - GroupItem Functions
    override func getItems<T>(filter: ((T) -> Bool)) -> [T] where T : NSManagedObject {
        saveItemExpectation?.fulfill()
        return []
    }
    
    override func updateDataEntity(group: GroupModel) {
        self.saveItemExpectation?.fulfill()
    }
    
    override func addGroup(title: String, recipes: [RecipeItem]) {
        let newGroup = NSEntityDescription.insertNewObject(forEntityName: "GroupItem", into: self.viewContext) as! GroupItem
        newGroup.title = title
        recipes.forEach { newGroup.addToRecipes($0) }
        self.group = newGroup
        self.saveItemExpectation?.fulfill()
    }
}
