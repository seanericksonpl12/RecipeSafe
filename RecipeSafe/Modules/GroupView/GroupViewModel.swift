//
//  GroupViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import Foundation
import SwiftUI

@MainActor class GroupViewModel: ObservableObject {
    
    @Published var group: GroupModel
    @Published var addRecipeSwitch: Bool = false
    @Published var deleteGroupSwitch: Bool = false
    @Published var editingEnabled: Bool = false
    @Published var selectedRecipes: [RecipeItem] = []
    
    private var dataManager: DataManager = DataManager()
    private var dismiss: DismissAction?
    
    init(group: GroupItem) {
        self.group = GroupModel(dataEntity: group)
    }
}

extension GroupViewModel {
    
    func getRecipes() -> [RecipeItem] {
        self.dataManager.getItems(filter: { $0.group != self.group.dataEntity } )
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
        self.group.recipes.remove(atOffsets: offsets)
        self.saveChanges()
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
