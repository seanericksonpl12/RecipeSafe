//
//  GroupViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import Foundation
import SwiftUI

class GroupViewModel: ObservableObject {
    
    // MARK: - Wrapped
    @Published var group: GroupModel
    @Published var addRecipeSwitch: Bool = false
    @Published var deleteGroupSwitch: Bool = false
    @Published var editingEnabled: Bool = false
    @Published var selectedRecipes: [RecipeItem] = []
    
    // MARK: - Private Properties
    @Service private var dataManager: DataManager!
    private var dismiss: Binding<PresentationMode>?
    
    // MARK: - Stored Properties
    private(set) var newRecipe: Recipe?
    
    // MARK: - Init
    init(group: GroupItem, newRecipe: Recipe? = nil) {
        self.group = GroupModel(dataEntity: group)
        self.newRecipe = newRecipe
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
        if var exit = dismiss {
            exit.wrappedValue.dismiss()
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
        if !editingEnabled {
            offsets.forEach {
                self.group.recipes[$0].group = nil
            }
        }
        self.group.recipes.remove(atOffsets: offsets)
        if !editingEnabled {
            self.dataManager.updateDataEntity(group: group)
        }
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
    
    func setUp(dismiss: Binding<PresentationMode>) {
        self.editingEnabled = false
        self.dismiss = dismiss
    }
}
