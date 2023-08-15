//
//  NetworkManagerTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/5/23.
//

import XCTest
import Combine
@testable import RecipeSafe

final class NetworkManagerTests: XCTestCase {
    
    var exp: XCTestExpectation!
    var finishedExp: XCTestExpectation!
    var cancellables: Set<AnyCancellable>!
    var network: NetworkManager!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.exp = XCTestExpectation()
        self.finishedExp = XCTestExpectation()
        self.cancellables = Set<AnyCancellable>()
        self.network = NetworkManager(configuration: .default)
    }
    
    override func tearDown() {
        self.cancellables.forEach { $0.cancel() }
    }
    
    func testGoodUrl() {
        let url = URL(string: "RecipeSafe://open-recipe?url=www.therecipecritic.com/easy-shrimp-tacos/")!
        var recievedRecipe: Recipe?
        network.networkRequest(url: url).sink { status in
            switch status{
            case .finished:
                self.finishedExp.fulfill()
            case .failure(_):
                XCTFail()
            }
        } receiveValue: { recipe in
            recievedRecipe = recipe
            self.exp.fulfill()
        }.store(in: &cancellables)
        wait(for: [exp, finishedExp], timeout: 5)
        XCTAssertEqual(recievedRecipe?.url?.absoluteString, "https://www.therecipecritic.com/easy-shrimp-tacos/")
    }
    
    func testBadUrl() {
        let url =  URL(string: "RecipeSafe://open-recipe?url=www.someurlthatisnotvalidanddoesnotactuallyexit.com")!
        network.networkRequest(url: url).sink { status in
            switch status{
            case .finished:
                XCTFail()
            case .failure(_):
                self.exp.fulfill()
            }
        } receiveValue: { recipe in
            XCTFail()
        }.store(in: &cancellables)
        wait(for: [exp], timeout: 5)
    }

}
