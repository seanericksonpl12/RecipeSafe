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
    
    var currentShoppingList: ShoppingList {
        get {
            if let data = self.data(forKey: UserDefaultsKey.shoppingList.rawValue) {
                let decoder = JSONDecoder()
                return try! decoder.decode(ShoppingList.self, from: data)
            } else {
                let encoder = JSONEncoder()
                let list = ShoppingList()
                let data = try? encoder.encode(list)
                self.set(data, forKey: UserDefaultsKey.shoppingList.rawValue)
                return list
            }
        }
        set {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(newValue)
            self.set(data, forKey: UserDefaultsKey.shoppingList.rawValue)
        }
    }
}
