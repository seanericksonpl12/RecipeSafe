//
//  JSONParserTests.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/5/23.
//

import XCTest
@testable import RecipeSafe

final class JSONParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testInvalidData() {
        let data = Data([0, 1, 92, 183])
        let parser = RecipeJSONParser(data: data)
        do {
            let _: Recipe = try parser.parse()
            XCTFail()
        } catch(URLError.cannotDecodeRawData) {
            return
        }
        catch { XCTFail() }
    }
    
    func testInvalidHTML() {
        let data = Data()
        let parser = RecipeJSONParser(data: data)
        do {
            let _: Recipe = try parser.parse()
            XCTFail()
        } catch {
            if !(error is NetworkError) {
                XCTFail()
            }
        }
    }
    
    func testValidHTMLFormat1() {
        let path = Bundle(identifier: "com.seane.RecipeSafeTests")?.path(forResource: "test_data_1", ofType: "html")
        let str = try? String(contentsOfFile: path!)
        let data = str?.data(using: .utf8, allowLossyConversion: true)
        let parser = RecipeJSONParser(data: data!)
        
        do {
            let recipe: Recipe = try parser.parse()
            XCTAssertEqual(recipe.title, "Test Recipe Name")
            XCTAssertEqual(recipe.description, "Test Description")
            XCTAssertEqual(recipe.ingredients, ["Ingredient 1", "Ingredient 2"])
            XCTAssertEqual(recipe.instructions, ["Instruction 1", "Instruction 2"])
            XCTAssertEqual(recipe.prepTime, "Test Prep Time")
            XCTAssertEqual(recipe.cookTime, "Test Cook Time")
        } catch {
            XCTFail()
        }
    }
    
    func testValidHTMLFormat2() {
        let path = Bundle(identifier: "com.seane.RecipeSafeTests")?.path(forResource: "test_data_2", ofType: "html")
        let str = try? String(contentsOfFile: path!)
        let data = str?.data(using: .utf8, allowLossyConversion: true)
        let parser = RecipeJSONParser(data: data!)
        
        do {
            let recipe: Recipe = try parser.parse()
            XCTAssertEqual(recipe.title, "Test Recipe Name")
            XCTAssertEqual(recipe.description, "Test Description")
            XCTAssertEqual(recipe.ingredients, ["Ingredient 1", "Ingredient 2"])
            XCTAssertEqual(recipe.instructions, ["Instruction 1", "Instruction 2"])
            XCTAssertEqual(recipe.prepTime, "Test Prep Time")
            XCTAssertEqual(recipe.cookTime, "Test Cook Time")
        } catch {
            XCTFail()
        }
    }
    
    func testValidHTMLFormat3() {
        let path = Bundle(identifier: "com.seane.RecipeSafeTests")?.path(forResource: "test_data_3", ofType: "html")
        let str = try? String(contentsOfFile: path!)
        let data = str?.data(using: .utf8, allowLossyConversion: true)
        let parser = RecipeJSONParser(data: data!)
        
        do {
            let recipe: Recipe = try parser.parse()
            XCTAssertEqual(recipe.title, "Test Recipe Name")
            XCTAssertEqual(recipe.description, "Test Description")
            XCTAssertEqual(recipe.ingredients, ["Ingredient 1", "Ingredient 2"])
            XCTAssertEqual(recipe.instructions, ["Instruction 1", "Instruction 2"])
            XCTAssertEqual(recipe.prepTime, "Test Prep Time")
            XCTAssertEqual(recipe.cookTime, "Test Cook Time")
        } catch {
            print(error)
            XCTFail()
        }
    }

}
