//
//  AppConfig.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/24/24.
//

import Foundation
import SwiftUI

struct AppConfig: Codable, Sendable, Injectable {
  
  struct Parameters: Encodable {
    let attestationKey: String?
  }
  
  var featureFlags: FeatureFlags
  var appHealth: AppHealth
  
  static var defaultValue: Self {
    .init(
      featureFlags: FeatureFlags(
        searchEnabled: false,
        recipeAnalysisEnabled: false
      ),
      appHealth: AppHealth(
        needsAttestation: true
      )
    )
  }
  
  private init(featureFlags: FeatureFlags, appHealth: AppHealth) {
    self.featureFlags = featureFlags
    self.appHealth = appHealth
  }
}

struct FeatureFlags: Codable, Sendable {
  var searchEnabled: Bool
  var recipeAnalysisEnabled: Bool
}

struct AppHealth: Codable {
  let needsAttestation: Bool
}

#if DEBUG
extension AppConfig {
  static let mock = AppConfig(featureFlags: FeatureFlags(searchEnabled: true, recipeAnalysisEnabled: true), appHealth: AppHealth(needsAttestation: false))
}
#endif
