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
    var dataManager: MockDataManager!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.dataStack = PersistenceController(inMemory: true)
        self.dataEntity = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as? RecipeItem
        self.dataManager = MockDataManager(viewContext: dataStack.container.viewContext)
        self.viewModel = ContentViewModel(dataManager: dataManager)
        try? dataStack.container.viewContext.save()
    }
    
    
    func testInitialLoad() {
        XCTAssertFalse(viewModel.customRecipeSheet)
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
    
    

}
