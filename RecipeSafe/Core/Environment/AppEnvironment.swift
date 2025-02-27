//
//  Environment.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/24/24.
//

import Foundation
import SwiftUI

struct AppEnvironment {
    private static let defaultUrl = "https://www.foreignspyware.com"
    private static let defaultAnalyticsUrl = "com.seane.recipesafe.dev"
    
    static let analyticsHostname = Bundle.main.infoDictionary?["AnalyticsUrl"] as? String
    static let baseUrl: String = Bundle.main.infoDictionary?["ServerUrl"] as? String ?? defaultUrl
    static var shouldMock: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
}

protocol Injectable {
    static var defaultValue: Self { get }
}

extension EnvironmentValues {
    @Entry var services: ServiceValues = .defaultValue
    @Entry var appConfig: AppConfig = .defaultValue
    @Entry var toolbarActions: ToolbarActions = .defaultValue
}
