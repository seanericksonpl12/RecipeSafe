//
//  IngredientGroup.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 12/24/24.
//
import Foundation
import SwiftUI

struct IngredientGroup: Identifiable {
    var shoppingListItem: ShoppingListItem
    var text: String
    var selected: Bool
    let id: UUID = UUID()
    
    init(shoppingListItem: ShoppingListItem) {
        self.shoppingListItem = shoppingListItem
        self.text = shoppingListItem.value ?? ""
        self.selected = shoppingListItem.selected
    }
}
