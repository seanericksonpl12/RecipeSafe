//
//  NetworkManagerTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/5/23.
//

import XCTest
@testable import RecipeSafe

final class NetworkManagerTests: XCTestCase {
    
    var exp: XCTestExpectation!
    var finishedExp: XCTestExpectation!
    var network: NetworkManager!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.exp = XCTestExpectation()
        self.finishedExp = XCTestExpectation()
        self.network = NetworkManager(configuration: .default)
    }
    
    func testGoodUrl() async {
        let url = URL(string: "RecipeSafe://open-recipe?url=www.therecipecritic.com/easy-shrimp-tacos/")!
        var recievedRecipe: Recipe?
        switch await network.networkRequest(url: url) {
        case .success(let recipe):
            recievedRecipe = recipe
            self.exp.fulfill()
        case .failure:
            XCTFail()
        }
        await fulfillment(of: [self.exp], timeout: 5)
        XCTAssertEqual(recievedRecipe?.url?.absoluteString, "https://www.therecipecritic.com/easy-shrimp-tacos/")
    }
    
    func testBadUrl() async {
        let url =  URL(string: "RecipeSafe://open-recipe?url=www.someurlthatisnotvalidanddoesnotactuallyexit.com")!
        switch await network.networkRequest(url: url) {
        case .success:
            XCTFail()
        case .failure:
            self.exp.fulfill()
        }
        await fulfillment(of: [self.exp], timeout: 5)
    }

}
