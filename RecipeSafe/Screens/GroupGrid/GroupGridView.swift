//
//  GroupView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import SwiftUI

struct GroupGridView: View {
    
    // MARK: - Environment
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn
    ) private var groups: FetchedResults<GroupItem>
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "group == nil")
    ) private var recipes: FetchedResults<RecipeItem>
    
    @Environment(\.services.groupData) var groupDataService
    @Environment(\.services.recipeData) var recipeDataService
    
    @Binding var navPath: NavigationPath
    @Binding var newRecipe: Recipe?
    @Binding var newRecipeSwitch: Bool
    
    @State var editingEnabled: Bool = false
    @State var addGroupSwitch: Bool = false
    @State var deleteGroupSwitch: Bool = false
    @State var newGroupText: String = ""
    @State var selectedRecipes: [RecipeItem] = []
    @State var newGroupColor: Int16?
    
    @State private var onDeckToDelete: GroupItem?
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navPath) {
            GeometryReader { geo in
                // MARK: - Empty View
                if groups.isEmpty && !editingEnabled {
                    EmptyListView(description: "empty.desc.2".localized)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
                
                // MARK: - Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: (CGFloat(geo.size.width) / 2.75)))]) {
                        if editingEnabled {
                            InsertGridButton(insertAction: { addGroup() },
                                             width: (geo.size.width / 2.75),
                                             height: (geo.size.width / 2.75))
                        }
                        ForEach(groups) { item in
                            if editingEnabled {
                                GridButton(isEditing: $editingEnabled,
                                           geoProxy: geo,
                                           group: item,
                                           deleteAction: { toggleDeleteGroup(item) })
                            } else {
                                NavigationLink {
                                    GroupView(group: GroupModel(dataEntity: item))
                                } label: {
                                    GridButton(isEditing: $editingEnabled,
                                               geoProxy: geo,
                                               group: item,
                                               deleteAction: { toggleDeleteGroup(item) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                }
                
                // MARK: - Background
                .scrollDisabled(groups.isEmpty && !editingEnabled)
                .scrollContentBackground(.hidden)
                .applyAppBackground(proxy: geo, isShown: !groups.isEmpty)
            }
            
            // MARK: - Toolbar
            .toolbar {
                ToolbarItem {
                    Button(editingEnabled ? "button.done".localized : "button.edit".localized) {
                        toggleEdit()
                    }
                    .frame(width: 60, height: 60)
                    .contentShape(Rectangle())
                }
            }
            
            // MARK: - Navigation
            .navigationDestination(for: GroupItem.self) { group in
                GroupView(group: GroupModel(dataEntity: group))
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeView(recipe: recipe, screen: .groups)
            }
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - Environment
            .environment(\.editMode, .constant(editingEnabled ? EditMode.active : EditMode.inactive))
            
            // MARK: - Popups
            .popover(isPresented: $addGroupSwitch) {
                NavigationStack {
                    NewGroupPopover(titleText: $newGroupText,
                                    selectedRecipes: $selectedRecipes,
                                    recipes: Array(recipes),
                                    color: ColorSet.color(newGroupColor))
                    .editableToolbar(
                        isEditing: $editingEnabled,
                        save: { saveNewGroup() },
                        cancel: { cancelNewGroup() }
                    )
                }
            }
            .popover(isPresented: $newRecipeSwitch) {
                if let recipeId = newRecipe?.dataEntity, let recipe = recipeDataService.objectWithId(recipeId) {
                    SelectGroupsView(
                        selectionAction: selectGroup,
                        cancelAction: cancel,
                        newRecipe: recipe
                    )
                }
            }
            .alert("group.alert.delete".localized, isPresented: $deleteGroupSwitch) {
                Button("button.delete".localized, role: .destructive) {
                    deleteOnDeck()
                }
            }
        }
        .pageLoad(.groups)
    }
}

extension GroupGridView {
    
    func selectGroup(_ group: GroupItem) {
        self.newRecipeSwitch = false
        guard let recipe = self.newRecipe else { return }
        
        try? recipeDataService.addToGroup(recipe, group)
        Task { @MainActor in
            self.navPath.append(group)
            self.navPath.append(recipe)
        }
    }
    
    func cancel() {
        self.newRecipeSwitch = false
        guard let recipe = self.newRecipe else { return }
        Task {  @MainActor in
            self.navPath.append(recipe)
        }
    }
    
    func toggleEdit() {
        withAnimation { self.editingEnabled.toggle() }
    }
    
    func addGroup() {
        self.newGroupText = ""
        self.selectedRecipes = []
        self.newGroupColor = try? groupDataService.getNewColor()
        withAnimation { addGroupSwitch = true }
    }
    
    func toggleDeleteGroup(_ group: GroupItem) {
        self.deleteGroupSwitch = true
        self.onDeckToDelete = group
    }
    
    func deleteOnDeck() {
        if let item = self.onDeckToDelete {
            groupDataService.viewContext.delete(item)
        }
    }
    
    func saveNewGroup() {
        let newGroup = (title: newGroupText, recipes: selectedRecipes, color: self.newGroupColor)
        try? groupDataService.create(newGroup)
        addGroupSwitch = false
    }
    
    func cancelNewGroup() {
        addGroupSwitch = false
        newGroupText = ""
        newGroupColor = nil
        selectedRecipes = []
    }
}

// MARK: - New Recipe Handling
extension GroupGridView {
    
    func handleNewRecipe(_ recipe: Recipe) {
        self.navPath = .init()
        self.newRecipe = recipe
        Task { @MainActor in
            self.newRecipeSwitch = true
        }
    }
}
