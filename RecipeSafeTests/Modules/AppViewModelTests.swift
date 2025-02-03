//
//  AppViewModelTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/15/23.
//

import XCTest
@testable import RecipeSafe

final class AppViewModelTests: XCTestCase {
    
    var viewModel: AppViewModel!
    var networkManager: MockNetworkManager!
    var dataManager: MockDataManager!
    var dataStack: PersistenceController!
    var url: URL!

    @MainActor override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.dataStack = PersistenceController(inMemory: true)
        self.dataManager = MockDataManager(viewContext: self.dataStack.container.viewContext)
        self.networkManager = MockNetworkManager()
        self.viewModel = AppViewModel(networkManager: self.networkManager)
        self.url = URL(string: "RecipeSafe://open-recipe?url=www.allrecipes.com/recipe/149975/beer-brats/")
    }
    
    @MainActor func testGoodUrl() {
        self.networkManager.returnValidInput = true
        XCTAssertNil(self.dataManager.recipe)
        let expectation = XCTestExpectation()
        self.dataManager.saveItemExpectation = expectation
        viewModel.onURLOpen(url: url)
        XCTAssertEqual(viewModel.viewState, .loading)
        XCTAssertFalse(viewModel.displayBadSite)
        wait(for: [dataManager.saveItemExpectation!], timeout: 5)
        XCTAssertEqual(viewModel.viewState, .successfullyLoaded)
        XCTAssertEqual(self.dataManager.recipe?.title, "Test Title")
        XCTAssertEqual(self.dataManager.recipe?.description, "Test Description")
        XCTAssertEqual(self.dataManager.recipe?.ingredients, ["i 1", "i 2"])
        XCTAssertEqual(self.dataManager.recipe?.instructions, ["in 1", "in 2"])
    }
    
    @MainActor func testBadUrl() {
        self.networkManager.returnValidInput = false
        viewModel.onURLOpen(url: url)
        let ex = XCTNSPredicateExpectation(predicate: NSPredicate(block: {_,_ in self.viewModel.displayBadSite}), object: self)
        wait(for: [ex], timeout: 5)
        XCTAssertEqual(viewModel.viewState, .failedToLoad)
    }
    
    @MainActor func testDuplicate() {
        self.networkManager.returnValidInput = true
        self.dataManager.findDuplicate = true
        viewModel.onURLOpen(url: url)
        wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate { _,_ in self.viewModel.viewState == .successfullyLoaded }, object: self)])
        XCTAssertTrue(viewModel.duplicateFound)
    }
    
    @MainActor func testOverwriteWithoutCopy() {
        self.networkManager.returnValidInput = true
        self.dataManager.findDuplicate = true
        let expectation = XCTestExpectation(description: "exp")
        let saveExpectation = XCTestExpectation(description: "save exp")
        self.dataManager.deleteItemExpectation = expectation
        self.dataManager.saveItemExpectation = saveExpectation
        viewModel.onURLOpen(url: url)
        wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate { _,_ in self.viewModel.viewState == .successfullyLoaded }, object: self)])
        viewModel.overwriteRecipe(deletingDup: true)
        
        wait(for: [expectation, saveExpectation], timeout: 5)
        
        XCTAssertEqual(self.dataManager.recipeToDelete?.title, "Test Duplicate")
        XCTAssertEqual(self.dataManager.recipe?.title, "Test Title")
    }
    
    @MainActor func testOverwriteWithCopy() {
        self.networkManager.returnValidInput = true
        self.dataManager.findDuplicate = true
        let saveExpectation = XCTestExpectation()
        self.dataManager.saveItemExpectation = saveExpectation
        viewModel.onURLOpen(url: url)
        wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate { _,_ in self.viewModel.viewState == .successfullyLoaded }, object: self)])
        viewModel.overwriteRecipe(deletingDup: false)
        wait(for: [saveExpectation], timeout: 5)
        
        XCTAssertNil(self.dataManager.recipeToDelete)
        XCTAssertEqual(self.dataManager.recipe?.title, "Test Title")
    }
    
    @MainActor func testCancelOverwrite() {
        self.viewModel.duplicateFound = true
        self.viewModel.cancelOverwrite()
        XCTAssertFalse(viewModel.duplicateFound)
    }

}
