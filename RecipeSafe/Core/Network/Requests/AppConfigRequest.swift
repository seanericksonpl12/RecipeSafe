//
//  AppConfigRequest.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/24/24.
//

import Foundation

struct AppConfigRequest: NetworkRequest {
    typealias Response = AppConfigModel

    var url: String  {
        AppEnvironment.baseUrl + "/api/recipe-safe/appConfig"
    }
    
    var method: HTTPMethod? { .get }
    var body: Data? { nil }
}
