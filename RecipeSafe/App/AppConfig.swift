//
//  AppConfig.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/24/24.
//

import Foundation
import SwiftUI
import Injector

@Observable
@Dependency
final class AppConfig: Sendable {
    
    static let defaultValue: (any Dependency) = AppConfig()
    
    enum LoadState {
        case loaded, loading, failed
    }
    
    private(set) var state: LoadState = .loading
    private(set) var model: AppConfigModel? = nil
    
    // TODO: - Return Model value once search functionality is ready
    var searchAvailable: Bool { false }
    
    init() {
        Task {
            await fetchAppConfig()
        }
    }
}


extension AppConfig {
    
    private func fetchAppConfig() async {
        let network = NetworkManager(configuration: .ephemeral)
        let result = await network.executeRequest(request: AppConfigRequest(), retries: 1)
        switch result {
        case .success(let appconfig):
            model = appconfig
            withAnimation(.linear) {
                state = .loaded
            }
        case .failure(let failure):
            state = .failed
        }
    }
}

struct AppConfigModel: Codable, Sendable {
    var featureFlags: FeatureFlags
}

struct FeatureFlags: Codable, Sendable {
    var searchEnabled: Bool
}
