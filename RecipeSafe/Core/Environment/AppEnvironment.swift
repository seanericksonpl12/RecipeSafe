//
//  Environment.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/24/24.
//

import Foundation

struct AppEnvironment {
    private static let defaultUrl = "https://www.foreignspyware.com"
    
    static let baseUrl: String = Bundle.main.infoDictionary?["ServerUrl"] as? String ?? defaultUrl
    
    static var shouldMock: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
}
