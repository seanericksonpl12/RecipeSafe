//
//  RecipeViewTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/2/23.
//

import XCTest
@testable import RecipeSafe
import CoreData

@MainActor final class RecipeViewTests: XCTestCase {
    
    var viewModel: RecipeViewModel!
    var dataEntity: RecipeItem?
    var persistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        viewModel = RecipeViewModel(recipe: Recipe())
        persistenceController = PersistenceController(inMemory: true)
    }
    
    func testInitialLoad() {
        XCTAssertFalse(viewModel.editingEnabled)
        XCTAssertFalse(viewModel.alertSwitch)
        XCTAssertEqual(viewModel.descriptionText, "")
    }

}
