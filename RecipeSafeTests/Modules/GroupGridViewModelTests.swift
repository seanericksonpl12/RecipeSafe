//
//  GroupGridViewModelTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/12/23.
//

import XCTest
import CoreData
@testable import RecipeSafe

@MainActor final class GroupGridViewModelTests: XCTestCase {
    
    var viewModel: GroupGridViewModel!
    var dataStack: PersistenceController!
    var dataManager: MockDataManager!
    var group: GroupItem!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.dataStack = PersistenceController(inMemory: true)
        self.dataManager = MockDataManager(viewContext: dataStack.container.viewContext)
        self.dataManager.saveItemExpectation = XCTestExpectation()
        self.dataManager.deleteItemExpectation = XCTestExpectation()
        self.group = NSEntityDescription.insertNewObject(forEntityName: "GroupItem", into: dataStack.container.viewContext) as? GroupItem
        self.group.title = "Test Group"
        self.viewModel = GroupGridViewModel(dataManager: self.dataManager)
    }
    
    func testInitialSetup() {
        XCTAssertFalse(viewModel.editingEnabled)
        XCTAssertFalse(viewModel.addGroupSwitch)
        XCTAssertFalse(viewModel.deleteGroupSwitch)
        XCTAssertTrue(viewModel.selectedRecipes.isEmpty)
        XCTAssertEqual(viewModel.newGroupText, "")
    }
    
    func testToggleEdit() {
        viewModel.editingEnabled = false
        viewModel.toggleEdit()
        XCTAssertTrue(viewModel.editingEnabled)
    }
    
    func testAddGroup() {
        viewModel.newGroupText = "Testing"
        viewModel.addGroup()
        XCTAssertEqual(viewModel.newGroupText, "")
        XCTAssertTrue(viewModel.addGroupSwitch)
    }
    
    func testToggleDeleteGroup() {
        viewModel.toggleDeleteGroup(self.group)
        XCTAssertTrue(viewModel.deleteGroupSwitch)
    }
    
    func testDeleteGroup() {
        viewModel.deleteGroup(self.group)
        wait(for: [dataManager.deleteItemExpectation!], timeout: 5)
        XCTAssertEqual(self.group, dataManager.groupToDelete)
    }
    
    func testDeleteOnDeck() {
        viewModel.toggleDeleteGroup(self.group)
        viewModel.deleteOnDeck()
        wait(for: [dataManager.deleteItemExpectation!], timeout: 5)
        XCTAssertEqual(self.group, dataManager.groupToDelete)
    }
    
    func testGetRecipes() {
        let arr = viewModel.getRecipes()
        wait(for: [dataManager.saveItemExpectation!], timeout: 5)
        XCTAssertTrue(arr.isEmpty)
    }
    
    func testSaveNewGroup() {
        viewModel.newGroupText = "Test Title"
        guard let r1 = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as? RecipeItem else {
            XCTFail()
            return
        }
        guard let r2 = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as? RecipeItem else {
            XCTFail()
            return
        }
        viewModel.selectedRecipes = [r1, r2]
        viewModel.saveNewGroup()
        wait(for: [dataManager.saveItemExpectation!], timeout: 5)
        XCTAssertEqual(dataManager.group?.title, "Test Title")
        XCTAssertEqual(dataManager.group?.recipes, [r1, r2])
    }
    
    func testCancelNewGroup() {
        viewModel.newGroupText = "Testing"
        viewModel.addGroupSwitch = true
        guard let r1 = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as? RecipeItem else {
            XCTFail()
            return
        }
        guard let r2 = NSEntityDescription.insertNewObject(forEntityName: "RecipeItem", into: dataStack.container.viewContext) as? RecipeItem else {
            XCTFail()
            return
        }
        viewModel.selectedRecipes = [r1, r2]
        viewModel.cancelNewGroup()
        XCTAssertTrue(viewModel.selectedRecipes.isEmpty)
        XCTAssertEqual(viewModel.newGroupText, "")
        XCTAssertFalse(viewModel.addGroupSwitch)
    }

}
