//
//  NetworkProtocolTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/4/23.
//

import XCTest
@testable import RecipeSafe

final class NetworkProtocolTests: XCTestCase {
    
    var network: NetworkManager!
    var expectation: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.network = NetworkManager(configuration: .default)
        self.expectation = XCTestExpectation(description: "Failed to complete request within timeout boundary.")
    }
    
    func testBadUrl() async {
        let request = RecipeRequest(url: "")
        switch await network.executeRequest(request: request, retries: 0) {
        case .success:
            XCTFail()
        case .failure(let error):
            if error is URLError {
                self.expectation.fulfill()
            }
        }
        await fulfillment(of: [self.expectation], timeout: 5)
    }
    
    func testBadRequest() async {
        let request = RecipeRequest(url: "https://github.com/seanericksonpl12")
        
        switch await network.executeRequest(request: request, retries: 0) {
        case .success(_):
            XCTFail()
        case .failure(let error):
            if error is NetworkError {
                self.expectation.fulfill()
            }
        }
        await fulfillment(of: [self.expectation], timeout: 5)
    }
    
    func testGoodRequest() async {
        // Use Mock request as data decoding will be tested in JSONParser tests
        let request = MockNetworkRequest(url: "https://therecipecritic.com/easy-shrimp-tacos/")
        switch await network.executeRequest(request: request, retries: 0) {
        case .success(let data):
            if !data.isEmpty {
                self.expectation.fulfill()
            }
        case .failure:
            XCTFail()
        }
        await fulfillment(of: [self.expectation], timeout: 5)
    }
    
    func testGetHTMLBadUrl() async {
        let url = URL(string: "https://someinvalidwebsitethatdoesntactuallyexist.com")!
        let request = URLRequest(url: url)
        
        switch await network.getHTML(request: request, retries: 0) {
        case .success(_):
            XCTFail()
        case .failure(_):
            self.expectation.fulfill()
        }
        await fulfillment(of: [self.expectation], timeout: 5)
    }
    
    func testGetHTMLGoodUrl() async {
        let url = URL(string: "https://therecipecritic.com/easy-shrimp-tacos/")!
        let request = URLRequest(url: url)
        
        switch await network.getHTML(request: request, retries: 0) {
        case .success(let string):
            if !string.isEmpty {
                self.expectation.fulfill()
            }
        case .failure:
            XCTFail()
        }
        await fulfillment(of: [self.expectation], timeout: 5)
    }
}
