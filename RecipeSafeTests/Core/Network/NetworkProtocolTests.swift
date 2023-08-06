//
//  NetworkProtocolTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/4/23.
//

import XCTest
import Combine
@testable import RecipeSafe

final class NetworkProtocolTests: XCTestCase {
    
    var network: NetworkManager!
    var expectation: XCTestExpectation!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        self.network = NetworkManager(configuration: .default)
        self.expectation = XCTestExpectation(description: "Failed to complete request within timeout boundary.")
        self.cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        self.cancellables.forEach { $0.cancel() }
    }
    
    func testBadUrl() {
        let request = RecipeRequest(url: "")
        network.executeRequest(request: request, retries: 0)
            .sink { status in
                switch status {
                case .finished:
                    XCTFail()
                case .failure(let error):
                    if error is URLError {
                        self.expectation.fulfill()
                    }
                }
            } receiveValue: { _ in
                XCTFail()
            }.store(in: &cancellables)
        wait(for: [self.expectation], timeout: 5)
    }
    
    func testBadRequest() {
        let request = RecipeRequest(url: "https://github.com/seanericksonpl12")
        network.executeRequest(request: request, retries: 0)
            .sink { status in
                switch status {
                case .finished:
                    XCTFail()
                case .failure(let error):
                    if error is NetworkError {
                        self.expectation.fulfill()
                    }
                }
            } receiveValue: { _ in
                XCTFail()
            }.store(in: &cancellables)
        wait(for: [self.expectation], timeout: 5)
    }
    
    func testGoodRequest() {
        // Use Mock request as data decoding will be tested in JSONParser tests
        let request = MockNetworkRequest(url: "https://therecipecritic.com/easy-shrimp-tacos/")
        let finishedExp = XCTestExpectation()
        network.executeRequest(request: request, retries: 0)
            .sink { status in
                switch status {
                case .finished:
                    finishedExp.fulfill()
                case .failure(_):
                    XCTFail()
                }
            } receiveValue: { data in
                if !data.isEmpty {
                    self.expectation.fulfill()
                }
            }.store(in: &cancellables)
        wait(for: [self.expectation, finishedExp], timeout: 5)
    }
    
    func testGetHTMLBadUrl() {
        let url = URL(string: "https://someinvalidwebsitethatdoesntactuallyexist.com")!
        let request = URLRequest(url: url)
        network.getHTML(request: request, retries: 0)
            .sink { status in
                switch status {
                case .finished:
                    XCTFail()
                case .failure(_):
                    self.expectation.fulfill()
                }
            } receiveValue: { string in
                XCTFail()
            }.store(in: &cancellables)
        wait(for: [self.expectation], timeout: 5)
    }
    
    func testGetHTMLGoodUrl() {
        let url = URL(string: "https://therecipecritic.com/easy-shrimp-tacos/")!
        let request = URLRequest(url: url)
        let finishedExp = XCTestExpectation()
        network.getHTML(request: request, retries: 0)
            .sink { status in
                switch status {
                case .finished:
                    finishedExp.fulfill()
                case .failure(_):
                    XCTFail()
                }
            } receiveValue: { string in
                if !string.isEmpty {
                    self.expectation.fulfill()
                }
            }.store(in: &cancellables)
        wait(for: [self.expectation, finishedExp], timeout: 5)
    }
    
}
