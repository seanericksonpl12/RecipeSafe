//
//  ServiceTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 10/6/24.
//

import XCTest
@testable import RecipeSafe

final class ServiceTests: XCTestCase {
    
    var root: RootStruct!
    var initCount: Int!
    
    override func setUp() {
        print("setup")
        self.initCount = 0
        ServiceRegister.addService(TestService { self.initCount += 1 })
        self.root = RootStruct()
    }
    
    override func tearDown() {
        self.root = nil
    }
    
    func testReferenceAtRoot() {
        root.testService.doNothing()
        
        let nested1 = root.nestedStruct
        let nested2 = root.nestedStruct.nestedStruct
        
        nested1.testService.doNothing()
        nested2.testService.doNothing()
        XCTAssertTrue(nested1.testService === nested2.testService)
        XCTAssertTrue(nested1.testService === root.testService)
        XCTAssertTrue(nested2.testService === root.testService)
    }
    
    func testRetainedReference() {
        let retainer = Nested1()
        retainer.testService.doNothing()
        
        autoreleasepool {
            let nested = Nested1()
            nested.testService.doNothing()
            XCTAssertEqual(initCount, 1)
        }
        
        autoreleasepool {
            let nested = Nested2()
            nested.testService.doNothing()
            XCTAssertEqual(initCount, 1)
        }
    }
    
    func testReleasedReference() {
        autoreleasepool {
            let nested = Nested1()
            nested.testService.doNothing()
            XCTAssertEqual(initCount, 1)
        }
        autoreleasepool {
            let nested = Nested2()
            nested.testService.doNothing()
            XCTAssertEqual(initCount, 2)
        }
    }
    
    func testLazyInit() {
        let nested = Nested1()
        XCTAssertEqual(initCount, 0)
        nested.testService.doNothing()
        XCTAssertEqual(initCount, 1)
    }
}

class TestService {
    
    init(_ initSwitch: @escaping () -> Void) {
        initSwitch()
    }
    
    func doNothing() {}
}

struct Nested1 {
    @Service var testService: TestService!
    var nestedStruct = Nested2()
}

struct Nested2 {
    @Service var testService: TestService!
}

struct RootStruct {
    @Service var testService: TestService!
    var nestedStruct = Nested1()
}
