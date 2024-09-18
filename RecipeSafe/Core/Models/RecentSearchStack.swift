//
//  RecentSearchStack.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/17/24.
//

import Foundation

struct RecentSearchStack {
    init() {
        let searches = UserDefaults.standard.recentSearches
        if searches.count > longMax {
            let sliced = Array(searches[0..<longMax])
            UserDefaults.standard.recentSearches = sliced
            self.storage = sliced
        } else {
            self.storage = Array(searches[0..<shortMax])
        }
    }
    
    let shortMax: Int = 3
    let longMax: Int = 30
    private var storage: [String]
    
    var recentArray: [String] { storage }
    var fullArray: [String] { UserDefaults.standard.recentSearches }
}

extension RecentSearchStack {
    
    mutating func add(_ value: String) {
        if storage.count >= shortMax {
            let _ = storage.popLast()
        }
        storage.insert(value, at: 0)
        if UserDefaults.standard.recentSearches.count >= longMax {
            let _ = UserDefaults.standard.recentSearches.popLast()
        }
        UserDefaults.standard.recentSearches.insert(value, at: 0)
    }
    
    mutating func clear() {
        UserDefaults.standard.recentSearches = []
        storage = []
    }
}
