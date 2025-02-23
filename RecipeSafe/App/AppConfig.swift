//
//  AppConfig.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/24/24.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class AppConfig: Sendable {
    
    enum LoadState {
        case loaded, loading, failed
    }
    
    private init() {}
    
    static let shared = AppConfig()
    
    
    private(set) var state: LoadState = .loading
    private(set) var model: AppConfigModel? = nil
    
    // TODO: - Return Model value once search functionality is ready
    var searchAvailable: Bool { false }
    
    func load(model: AppConfigModel) {
        self.model = model
        self.state = .loaded
    }
    
    func loadFailed() {
        self.state = .failed
    }
}

struct AppConfigModel: Codable, Sendable {
    var featureFlags: FeatureFlags
}

struct FeatureFlags: Codable, Sendable {
    var searchEnabled: Bool
}
