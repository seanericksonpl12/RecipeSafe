//
//  GroupViewModelTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/11/23.
//

import XCTest
import CoreData
@testable import RecipeSafe

@MainActor final class GroupViewModelTests: XCTestCase {
    
    var viewModel: GroupViewModel!
    var dataStack: PersistenceController!
    var dataManager: MockDataManager!
    var group: GroupItem!
    var recipe: RecipeItem!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.dataStack = PersistenceController(inMemory: true)
        self.dataManager = MockDataManager(viewContext: dataStack.container.viewContext)
        self.group = NSEntityDescription.insertNewObject(forEntityName: "GroupItem", into: dataStack.container.viewContext) as? GroupItem
        self.recipe = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as? RecipeItem
        self.group.title = "Test Group"
        self.group.addToRecipes(recipe)
        self.viewModel = GroupViewModel(group: self.group, dataManager: self.dataManager)
    }
    
    func testInitialSetup() {
        XCTAssertFalse(viewModel.addRecipeSwitch)
        XCTAssertFalse(viewModel.deleteGroupSwitch)
        XCTAssertFalse(viewModel.editingEnabled)
        XCTAssertTrue(viewModel.selectedRecipes.isEmpty)
    }
    
    func testGetRecipes() {
        XCTAssertTrue(viewModel.getRecipes().isEmpty)
    }
    
    func testToggleDelete() {
        XCTAssertFalse(viewModel.deleteGroupSwitch)
        viewModel.toggleDelete()
        XCTAssertTrue(viewModel.deleteGroupSwitch)
    }
    
    func testDeleteSelf() {
        dataManager.deleteItemExpectation = XCTestExpectation()
        viewModel.deleteSelf()
        wait(for: [dataManager.deleteItemExpectation!], timeout: 5)
        XCTAssertEqual(viewModel.group.dataEntity, dataManager.groupToDelete)
    }
    
    func testSaveChanges() {
        viewModel.editingEnabled = true
        dataManager.saveItemExpectation = XCTestExpectation()
        viewModel.saveChanges()
        wait(for: [dataManager.saveItemExpectation!], timeout: 5)
        XCTAssertFalse(viewModel.editingEnabled)
    }
    
    func testCancelChanges() {
        viewModel.editingEnabled = true
        viewModel.group.title = "Edited Title"
        viewModel.group.recipes = []
        viewModel.cancelChanges()
        XCTAssertEqual(viewModel.group.title, "Test Group")
        XCTAssertEqual(viewModel.group.recipes, [self.recipe])
        XCTAssertFalse(viewModel.editingEnabled)
    }
    
    func testRemoveRecipe() {
        dataManager.saveItemExpectation = XCTestExpectation()
        viewModel.removeRecipe(at: IndexSet(integer: 0))
        wait(for: [dataManager.saveItemExpectation!], timeout: 5)
        XCTAssertTrue(viewModel.group.recipes.isEmpty)
    }
    
    func testSaveAddedRecipes() {
        viewModel.addRecipeSwitch = true
        guard let r1 = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as? RecipeItem else {
            XCTFail()
            return
        }
        guard let r2 = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as? RecipeItem else {
            XCTFail()
            return
        }
        r1.title = "recipe 1"
        r2.title = "recipe 2"
        viewModel.selectedRecipes = [r1, r2]
        dataManager.saveItemExpectation = XCTestExpectation()
        viewModel.saveAddedRecipes()
        wait(for: [dataManager.saveItemExpectation!], timeout: 5)
        XCTAssertEqual(viewModel.group.recipes, [self.recipe, r1, r2])
        XCTAssertTrue(viewModel.selectedRecipes.isEmpty)
        
    }

}
