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
    var recipeToDelete: RecipeItem?
    
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
    
    override func deleteItem(_ item: RecipeItem) {
        self.recipeToDelete = item
        deleteItemExpectation?.fulfill()
    }
}
