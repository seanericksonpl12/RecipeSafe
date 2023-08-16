//
//  AppViewModelTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/15/23.
//

import XCTest
@testable import RecipeSafe

@MainActor final class AppViewModelTests: XCTestCase {
    
    var viewModel: AppViewModel!
    var networkManager: MockNetworkManager!
    var dataManager: MockDataManager!
    var dataStack: PersistenceController!
    var url: URL!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.dataStack = PersistenceController(inMemory: true)
        self.dataManager = MockDataManager(viewContext: self.dataStack.container.viewContext)
        self.networkManager = MockNetworkManager()
        self.viewModel = AppViewModel(networkManager: self.networkManager, dataManager: self.dataManager)
        self.url = URL(string: "RecipeSafe://open-recipe?url=www.allrecipes.com/recipe/149975/beer-brats/")
    }
    
    func testGoodUrl() {
        self.networkManager.returnValidInput = true
        XCTAssertNil(self.dataManager.recipe)
        let expectation = XCTestExpectation()
        self.dataManager.saveItemExpectation = expectation
        viewModel.onURLOpen(url: url)
        XCTAssertEqual(viewModel.viewState, .successfullyLoaded)
        XCTAssertFalse(viewModel.displayBadSite)
        wait(for: [dataManager.saveItemExpectation!], timeout: 5)
        XCTAssertEqual(self.dataManager.recipe?.title, "Test Title")
        XCTAssertEqual(self.dataManager.recipe?.description, "Test Description")
        XCTAssertEqual(self.dataManager.recipe?.ingredients, ["i 1", "i 2"])
        XCTAssertEqual(self.dataManager.recipe?.instructions, ["in 1", "in 2"])
    }
    
    func testBadUrl() {
        self.networkManager.returnValidInput = false
        viewModel.onURLOpen(url: url)
        let ex = XCTNSPredicateExpectation(predicate: NSPredicate(block: {_,_ in self.viewModel.displayBadSite}), object: self)
        wait(for: [ex], timeout: 5)
        XCTAssertEqual(viewModel.viewState, .failedToLoad)
    }
    
    func testDuplicate() {
        self.networkManager.returnValidInput = true
        self.dataManager.findDuplicate = true
        viewModel.onURLOpen(url: url)
        XCTAssertTrue(viewModel.duplicateFound)
    }
    
    func testOverwriteWithoutCopy() {
        self.networkManager.returnValidInput = true
        self.dataManager.findDuplicate = true
        let expectation = XCTestExpectation()
        let saveExpectation = XCTestExpectation()
        self.dataManager.deleteItemExpectation = expectation
        self.dataManager.saveItemExpectation = saveExpectation
        viewModel.onURLOpen(url: url)
        viewModel.overwriteRecipe(deletingDup: true)
        wait(for: [expectation, saveExpectation], timeout: 5)
        
        XCTAssertEqual(self.dataManager.recipeToDelete?.title, "Test Duplicate")
        XCTAssertEqual(self.dataManager.recipe?.title, "Test Title")
    }
    
    func testOverwriteWithCopy() {
        self.networkManager.returnValidInput = true
        self.dataManager.findDuplicate = true
        let saveExpectation = XCTestExpectation()
        self.dataManager.saveItemExpectation = saveExpectation
        viewModel.onURLOpen(url: url)
        viewModel.overwriteRecipe(deletingDup: false)
        wait(for: [saveExpectation], timeout: 5)
        
        XCTAssertNil(self.dataManager.recipeToDelete)
        XCTAssertEqual(self.dataManager.recipe?.title, "Test Title")
    }
    
    func testCancelOverwrite() {
        self.viewModel.duplicateFound = true
        self.viewModel.cancelOverwrite()
        XCTAssertFalse(viewModel.duplicateFound)
    }

}
