//
//  ContentViewTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/2/23.
//

import XCTest
@testable import RecipeSafe
import SwiftUI
import CoreData

@MainActor final class ContentViewModelTests: XCTestCase {

    var viewModel: ContentViewModel!
    var dataEntity: RecipeItem!
    var dataStack: PersistenceController!
    var networkManager: MockNetworkManager!
    var dataManager: MockDataManager!
    var url: URL!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.dataStack = PersistenceController(inMemory: true)
        self.dataEntity = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as? RecipeItem
        self.dataManager = MockDataManager(viewContext: dataStack.container.viewContext)
        self.networkManager = MockNetworkManager()
        self.viewModel = ContentViewModel(dataManager: dataManager, networkManager: networkManager)
        try? dataStack.container.viewContext.save()
        self.url = URL(string: "RecipeSafe://open-recipe?url=www.allrecipes.com/recipe/149975/beer-brats/")
    }
    
    
    func testInitialLoad() {
        XCTAssertEqual(viewModel.viewState, ViewState.started)
        XCTAssertFalse(viewModel.displayBadSite)
        XCTAssertFalse(viewModel.customRecipeSheet)
        XCTAssertFalse(viewModel.duplicateFound)
        XCTAssertTrue(viewModel.navPath.isEmpty)
        XCTAssertEqual(viewModel.searchText, "")
    }
    
    func testSearchList() {
        let dataEntity2 = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as! RecipeItem
        let dataEntity3 = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as! RecipeItem
        dataEntity.title = "Porsche"
        dataEntity2.title = "Chevy"
        dataEntity3.title = "Ford"
        let list: [RecipeItem] = [dataEntity, dataEntity2, dataEntity3]
        
        XCTAssertEqual(viewModel.searchList(list), list)
        viewModel.searchText = "c"
        XCTAssertTrue(viewModel.searchList(list).contains(where: {$0.title == "Porsche"}))
        XCTAssertTrue(viewModel.searchList(list).contains(where: {$0.title == "Chevy"}))
        XCTAssertFalse(viewModel.searchList(list).contains(where: {$0.title == "Ford"}))
        viewModel.searchText = "Ferrari"
        XCTAssertTrue(viewModel.searchList(list).isEmpty)
    }
    
    func testGoodUrl() {
        self.networkManager.returnValidInput = true
        XCTAssertNil(self.dataManager.recipe)
        viewModel.onURLOpen(url: url)
        XCTAssertEqual(viewModel.viewState, .successfullyLoaded)
        XCTAssertFalse(viewModel.displayBadSite)
        let expectation = XCTestExpectation()
        self.dataManager.saveItemExpectation = expectation
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(self.dataManager.recipe?.title, "Test Title")
        XCTAssertEqual(self.dataManager.recipe?.description, "Test Description")
        XCTAssertEqual(self.dataManager.recipe?.ingredients, ["i 1", "i 2"])
        XCTAssertEqual(self.dataManager.recipe?.instructions, ["in 1", "in 2"])
        XCTAssertFalse(viewModel.navPath.isEmpty)
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
