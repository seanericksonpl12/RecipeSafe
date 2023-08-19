//
//  GroupViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import Foundation
import SwiftUI

@MainActor class GroupViewModel: ObservableObject {
    
    // MARK: - Wrapped
    @Published var group: GroupModel
    @Published var addRecipeSwitch: Bool = false
    @Published var deleteGroupSwitch: Bool = false
    @Published var editingEnabled: Bool = false
    @Published var selectedRecipes: [RecipeItem] = []
    @Published var goToNewRecipe: Bool
    
    // MARK: - Private Properties
    private var dataManager: DataManager
    private var dismiss: DismissAction?
    
    // MARK: - Stored Properties
    private(set) var newRecipe: Recipe?
    
    // MARK: - Init
    init(group: GroupItem, newRecipe: Recipe? = nil, dataManager: DataManager = DataManager()) {
        self.group = GroupModel(dataEntity: group)
        self.dataManager = dataManager
        if newRecipe != nil {
            self.goToNewRecipe = true
            self.newRecipe = newRecipe
        } else {
            self.goToNewRecipe = false
        }
    }
}

// MARK: - Functions
extension GroupViewModel {
    
    func getRecipes() -> [RecipeItem] {
        self.dataManager.getItems(filter: { $0.group == nil } )
    }
    
    func toggleDelete() {
        self.deleteGroupSwitch = true
    }
    
    func deleteSelf() {
        self.dataManager.deleteItem(group.dataEntity)
        if let exit = dismiss {
            exit.callAsFunction()
        }
    }
    
    func saveChanges() {
        withAnimation {
            self.editingEnabled = false
        }
        self.dataManager.updateDataEntity(group: group)
    }
    
    func cancelChanges() {
        withAnimation {
            self.editingEnabled = false
        }
        if let title = group.dataEntity.title {
            self.group.title = title
        }
        if let recipes = group.dataEntity.recipes?.array as? [RecipeItem] {
            self.group.recipes = recipes
        }
    }
    
    func removeRecipe(at offsets: IndexSet) {
        offsets.forEach {
            self.group.recipes[$0].group = nil
        }
        self.group.recipes.remove(atOffsets: offsets)
        self.dataManager.updateDataEntity(group: group)
    }
    
    func moveRecipes(from start: IndexSet, to end: Int) {
        self.group.recipes.move(fromOffsets: start, toOffset: end)
    }
    
    func saveAddedRecipes() {
        self.addRecipeSwitch = false
        self.group.recipes.append(contentsOf: self.selectedRecipes)
        self.saveChanges()
        self.selectedRecipes = []
    }
    
    func setUp(dismiss: DismissAction) {
        self.editingEnabled = false
        self.dismiss = dismiss
    }
}
