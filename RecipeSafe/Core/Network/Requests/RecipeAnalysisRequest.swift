//
//  RecipeAnalysisRequest.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/3/25.
//

import Foundation

struct RecipeAnalysisResponse: Decodable {
    let title: String?
    let description: String?
    let ingredients: [String]?
    let instructions: [String]?
}

struct RecipeAnalysisRequest: NetworkRequest {
    
    typealias Response = RecipeAnalysisResponse
    
    var url: String { AppEnvironment.baseUrl + "/api/recipe-safe/classify" }
    var token: String
    var imageData: String
    var method: HTTPMethod? { .post }
    var header: [String : String] { ["Authorization": "Bearer \(self.token)", "User-Agent": "recipesafe"] }
    var body: Data? { try? JSONSerialization.data(withJSONObject: ["image": imageData]) }
    
    init(imageData: Data) throws {
        let secrets = try FileUtility.fetchPlist(name: "secrets")
        guard let token = secrets["RECIPE_SAFE_TOKEN"] else {
            throw URLError.init(.userAuthenticationRequired)
        }
        self.imageData = "data:image/jpeg;base64,".appending(imageData.base64EncodedString())
        self.token = token
    }
}
