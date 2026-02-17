//
//  UserDefaultsExtensions.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/16/23.
//

import Foundation

fileprivate enum UserDefaultsKey: String {
  case hasLaunchedBefore
  case recentSearches
  case shoppingList
  case hasMigratedDb
  case hasMigratedCoreData
}

// MARK: - Has Launched
extension UserDefaults {
  
  var hasLaunchedBefore: Bool {
    if self.bool(forKey: UserDefaultsKey.hasLaunchedBefore.rawValue) == false {
      self.set(true, forKey: UserDefaultsKey.hasLaunchedBefore.rawValue)
      return false
    }
    return true
  }
  
  var recentSearches: [String] {
    get{ self.stringArray(forKey: UserDefaultsKey.recentSearches.rawValue) ?? [] }
    set { self.set(newValue as Any, forKey: UserDefaultsKey.recentSearches.rawValue) }
  }
  
  var hasMigratedDb: Bool {
    if self.bool(forKey: UserDefaultsKey.hasMigratedDb.rawValue) == false {
      self.set(true, forKey: UserDefaultsKey.hasMigratedDb.rawValue)
      return false
    }
    return true
  }

  var hasMigratedCoreData: Bool {
    get { self.bool(forKey: UserDefaultsKey.hasMigratedCoreData.rawValue) }
    set { self.set(newValue, forKey: UserDefaultsKey.hasMigratedCoreData.rawValue) }
  }
}
