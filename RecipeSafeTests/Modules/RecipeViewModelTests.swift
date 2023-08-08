//
//  RecipeViewTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/2/23.
//

import XCTest
@testable import RecipeSafe
import CoreData

@MainActor final class RecipeViewModelTests: XCTestCase {
    
    var viewModel: RecipeViewModel!
    var dataEntity: RecipeItem!
    var dataStack: PersistenceController!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.dataStack = PersistenceController(inMemory: true)
        self.viewModel = RecipeViewModel(recipe: Recipe(), dataManager: DataManager(viewContext: self.dataStack.container.viewContext))
        self.dataEntity = RecipeItem(context: self.dataStack.container.viewContext)
        viewModel.recipe.dataEntity = self.dataEntity
    }
    
    func testInitialLoad() {
        XCTAssertFalse(viewModel.editingEnabled)
        XCTAssertFalse(viewModel.alertSwitch)
        XCTAssertEqual(viewModel.descriptionText, "")
    }
    
    func testSaveChanges() {
        viewModel.editingEnabled = true
        viewModel.descriptionText = "test description"
        viewModel.saveChanges()
        XCTAssertFalse(viewModel.editingEnabled)
        XCTAssertEqual(viewModel.recipe.description, "test description")
    }
    
    func testCancelEditing() {
        let exp1 = XCTNSPredicateExpectation(predicate: NSPredicate(block: {_,_ in return self.viewModel.recipe.ingredients == ["i 1", "i 2"]}), object: self)
        let exp2 = XCTNSPredicateExpectation(predicate: NSPredicate(block: {_,_ in return self.viewModel.recipe.instructions == ["is 1", "is 2"]}), object: self)
        viewModel.editingEnabled = true
        dataEntity.title = "Test Title"
        dataEntity.desc = "Test Desc"
        let i1 = Ingredient(context: dataStack.container.viewContext)
        let i2 = Ingredient(context: dataStack.container.viewContext)
        let is1 = Instruction(context: dataStack.container.viewContext)
        let is2 = Instruction(context: dataStack.container.viewContext)
        
        i1.value = "i 1"
        i2.value = "i 2"
        is1.value = "is 1"
        is2.value = "is 2"
        
        dataEntity.ingredients = [i1, i2]
        dataEntity.instructions = [is1, is2]
        viewModel.recipe.title = "Edited Title"
        viewModel.recipe.description = "Edited Description"
        viewModel.cancelEditing()
        
        XCTAssertFalse(viewModel.editingEnabled)
        XCTAssertEqual(viewModel.recipe.title, "Test Title")
        XCTAssertEqual(viewModel.recipe.description, "Test Desc")
        wait(for: [exp1, exp2], timeout: 5)
    }
    
    func testDeleteFromLists() {
        let index = IndexSet(arrayLiteral: 0, 2)
        viewModel.recipe.ingredients = ["1", "2", "3", "4"]
        viewModel.recipe.instructions = ["a", "b", "c", "d"]
        viewModel.deleteFromIngr(offsets: index)
        viewModel.deleteFromInst(offsets: index)
        
        XCTAssertEqual(viewModel.recipe.ingredients, ["2", "4"])
        XCTAssertEqual(viewModel.recipe.instructions, ["b", "d"])
    }
    
    func testDeleteSelf() {
        XCTAssertNotNil(viewModel.recipe.dataEntity)
        viewModel.deleteSelf()
        XCTAssertNil(viewModel.recipe.dataEntity)
    }

}
