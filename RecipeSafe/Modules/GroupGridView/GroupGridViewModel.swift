//
//  GroupViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import Foundation
import SwiftUI
import Combine

@MainActor class GroupGridViewModel: ObservableObject {
    
    // MARK: - Wrappers
    @Published var editingEnabled: Bool = false
    @Published var addGroupSwitch: Bool = false
    @Published var deleteGroupSwitch: Bool = false
    @Published var newGroupText: String = ""
    @Published var selectedRecipes: [RecipeItem] = []
    
    // MARK: - Private Properties
    private var onDeckToDelete: GroupItem?
    private var dataManager: DataManager
    
    // MARK: - Init
    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager
    }
}

// MARK: - Functions
extension GroupGridViewModel {
    
    func toggleEdit() {
        withAnimation {
            self.editingEnabled.toggle()
        }
    }
    
    func addGroup() {
        self.newGroupText = ""
        withAnimation {
            addGroupSwitch = true
        }
    }
    
    func toggleDeleteGroup(_ group: GroupItem) {
        self.deleteGroupSwitch = true
        self.onDeckToDelete = group
    }
    
    func deleteGroup(_ group: GroupItem) {
        dataManager.deleteItem(group)
    }
    
    func deleteOnDeck() {
        if let item = self.onDeckToDelete {
            self.deleteGroup(item)
        }
    }
    
    func getRecipes() -> [RecipeItem] {
        return dataManager.getItems(filter: { $0.group == nil })
    }
    
    func saveNewGroup() {
        dataManager.addGroup(title: newGroupText, recipes: selectedRecipes)
        addGroupSwitch = false
    }
    
    func cancelNewGroup() {
        addGroupSwitch = false
        newGroupText = ""
        selectedRecipes = []
    }
}
