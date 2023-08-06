//
//  CreateRecipeViewModelTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/3/23.
//

import XCTest
@testable import RecipeSafe

@MainActor final class CreateRecipeViewModelTests: XCTestCase {

    var viewModel: CreateRecipeViewModel!
    var dataEntity: RecipeItem!
    var dataStack: PersistenceController!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.dataStack = PersistenceController(inMemory: true)
        self.viewModel = CreateRecipeViewModel(dataManager: DataManager(viewContext: self.dataStack.container.viewContext))
        self.dataEntity = RecipeItem(context: self.dataStack.container.viewContext)
        viewModel.recipe.dataEntity = self.dataEntity
    }
    
    func testInitialLoad() {
        XCTAssertEqual(viewModel.recipe.title, "")
        XCTAssertNil(viewModel.recipe.description)
        XCTAssertEqual(viewModel.recipe.ingredients.count, 1)
        XCTAssertEqual(viewModel.recipe.instructions.count, 1)
        XCTAssertTrue(viewModel.editingEnabled)
    }
    
    func testSaveChanges() {
        viewModel.recipe.title = ""
        viewModel.descriptionText = "Test Description"
        viewModel.recipe.ingredients = ["i1", ""]
        viewModel.recipe.instructions = ["is1", ""]
        viewModel.saveChanges()
        
        XCTAssertEqual(viewModel.recipe.title, "New Recipe")
        XCTAssertEqual(viewModel.recipe.ingredients, ["i1"])
        XCTAssertEqual(viewModel.recipe.instructions, ["is1"])
        XCTAssertEqual(viewModel.recipe.description, "Test Description")
    }

}
