//
//  DataManagerTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/5/23.
//

import XCTest
import CoreData
@testable import RecipeSafe

final class DataManagerTests: XCTestCase {

    var dataManager: DataManager!
    var dataStack: PersistenceController!
    var testRecipe: Recipe!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.dataStack = PersistenceController(inMemory: true)
        self.dataManager = DataManager(viewContext: self.dataStack.container.viewContext)
        self.testRecipe = Recipe(title: "Test Title",
                                 description: "Test Description",
                                 ingredients: ["i 1", "i 2"],
                                 instructions: ["in 1", "in 2"],
                                 img: .none,
                                 url: nil,
                                 prepTime: "Test Prep",
                                 cookTime: "Test Cook")
    }

    func testSaveItem() {
        let newRecipe: RecipeItem? = dataManager.saveItem(self.testRecipe)
        
        XCTAssertNotNil(newRecipe)
        XCTAssertEqual(newRecipe?.title, "Test Title")
        XCTAssertEqual(newRecipe?.desc, "Test Description")
        var ing = newRecipe?.ingredients?.firstObject as? Ingredient
        XCTAssertEqual(ing?.value, "i 1")
        var ins = newRecipe?.instructions?.firstObject as? Instruction
        XCTAssertEqual(ins?.value, "in 1")
        
        let request = try? dataStack.container.viewContext.fetch(NSFetchRequest(entityName: "RecipeItem"))
        let recipes = request as? [RecipeItem]
        let foundRecipe = recipes?.first(where: {$0.id == newRecipe?.id})
        
        XCTAssertNotNil(foundRecipe)
        XCTAssertEqual(foundRecipe, newRecipe)
        XCTAssertEqual(foundRecipe?.desc, "Test Description")
        ing = foundRecipe?.ingredients?.firstObject as? Ingredient
        XCTAssertEqual(ing?.value, "i 1")
        ins = foundRecipe?.instructions?.firstObject as? Instruction
        XCTAssertEqual(ins?.value, "in 1")
    }
    
    func testDeleteItem() {
        let item = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as! RecipeItem
        var request = try? dataStack.container.viewContext.fetch(NSFetchRequest(entityName: "RecipeItem"))
        var recipes = request as? [RecipeItem]
        var foundRecipe = recipes?.first(where: {$0.id == item.id})
        XCTAssertNotNil(foundRecipe)
        
        dataManager.deleteItem(item)
        request = try? dataStack.container.viewContext.fetch(NSFetchRequest(entityName: "RecipeItem"))
        recipes = request as? [RecipeItem]
        foundRecipe = recipes?.first(where: {$0.id == item.id})
        XCTAssertNil(foundRecipe)
    }
    
    func testUpdateDataEntity() {
        let item = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as! RecipeItem
        testRecipe.dataEntity = item
        
        dataManager.updateDataEntity(recipe: testRecipe)
        XCTAssertEqual(item.title, "Test Title")
        XCTAssertEqual(item.desc, "Test Description")
        let ing = item.ingredients?.firstObject as? Ingredient
        XCTAssertEqual(ing?.value, "i 1")
        let ins = item.instructions?.firstObject as? Instruction
        XCTAssertEqual(ins?.value, "in 1")
    }
    
    func testDeleteDataEntity() {
        let item = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as! RecipeItem
        testRecipe.dataEntity = item
        var request = try? dataStack.container.viewContext.fetch(NSFetchRequest(entityName: "RecipeItem"))
        var recipes = request as? [RecipeItem]
        var foundRecipe = recipes?.first(where: {$0.id == item.id})
        XCTAssertNotNil(foundRecipe)
        
        dataManager.deleteDataEntity(recipe: testRecipe)
        request = try? dataStack.container.viewContext.fetch(NSFetchRequest(entityName: "RecipeItem"))
        recipes = request as? [RecipeItem]
        foundRecipe = recipes?.first(where: {$0.id == item.id})
        XCTAssertNil(foundRecipe)
    }
    
    func testFindDuplicates() {
        let item = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as! RecipeItem
        item.title = "Test Item"
        item.desc = "Test Description"
        item.url = URL(string: "https://github.com/seanericksonpl12")
        
        testRecipe.url = URL(string: "https://github.com/seanericksonpl12")
        let foundItem = dataManager.findDuplicates(testRecipe)
        XCTAssertEqual(foundItem, item)
    }
}
