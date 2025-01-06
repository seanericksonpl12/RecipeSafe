//
//  IngredientGroup.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 12/24/24.
//
import Foundation
import SwiftUI

struct IngredientGroup: Identifiable {
    var text: String
    var ingredient: Ingredient
    var selected: Bool
    let id: UUID = UUID()
    
    init(ingredient: Ingredient, selected: Bool) {
        self.text = ingredient.value ?? ""
        self.ingredient = ingredient
        self.selected = selected
    }
}
