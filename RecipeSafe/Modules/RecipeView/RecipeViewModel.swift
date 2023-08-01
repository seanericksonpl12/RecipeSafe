//
//  RecipeViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/18/23.
//

import Foundation
import SwiftUI
import Combine
import CoreData


@MainActor class RecipeViewModel: EditableRecipeModel {
   
    @Published var recipe: Recipe
    @Published var editingEnabled: Bool = false
    @Published var descriptionText: String = ""
    @Published var alertSwitch: Bool = false
    
    var dismiss: DismissAction?
    
    var saveAction: () -> Void {
        { self.saveChanges() }
    }
    
    var deleteAction: () -> Void {
        { self.toggleAlert() }
    }
    
    var cancelAction: () -> Void {
        { self.cancelEditing() }
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.descriptionText = recipe.description ?? ""
    }
}

