//
//  UserDefaultsExtensions.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/16/23.
//

import Foundation

// MARK: - Has Launched
extension UserDefaults {
    
    var hasLaunchedBefore: Bool {
        if self.bool(forKey: "hasLaunchedBefore") == false {
            self.set(true, forKey: "hasLaunchedBefore")
            return false
        }
        return true
    }
}
