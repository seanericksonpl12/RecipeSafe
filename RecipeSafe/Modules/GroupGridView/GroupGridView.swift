//
//  GroupView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import SwiftUI

struct GroupGridView: View {
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var groups: FetchedResults<GroupItem>
    
    // MARK: - ViewModel
    @StateObject var viewModel: GroupGridViewModel
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $viewModel.navPath) {
            GeometryReader { geo in
                // MARK: - Empty View
                if groups.isEmpty && !viewModel.editingEnabled {
                    EmptyListView(description: "empty.desc.2".localized)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
                
                // MARK: - Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: (CGFloat(geo.size.width) / 2.75)))]) {
                        if viewModel.editingEnabled {
                            InsertGridButton(insertAction: { viewModel.addGroup() },
                                             width: (geo.size.width / 2.75),
                                             height: (geo.size.width / 2.75))
                        }
                        ForEach(groups) { item in
                            if viewModel.editingEnabled {
                                GridButton(isEditing: $viewModel.editingEnabled,
                                           geoProxy: geo,
                                           group: item,
                                           deleteAction: { self.viewModel.toggleDeleteGroup(item) })
                            } else {
                                NavigationLink {
                                    GroupView(viewModel: GroupViewModel(group: item))
                                } label: {
                                    GridButton(isEditing: $viewModel.editingEnabled,
                                               geoProxy: geo,
                                               group: item,
                                               deleteAction: {self.viewModel.toggleDeleteGroup(item)})
                                }
                            }
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                }
                
                // MARK: - Background
                .scrollDisabled(groups.isEmpty && !viewModel.editingEnabled)
                .scrollContentBackground(.hidden)
                .background {
                    Image("logo-background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing)
                        .ignoresSafeArea(.all)
                        .opacity(groups.isEmpty ? 0.0 : 0.3)
                }
            }
            
            // MARK: - Toolbar
            .toolbar {
                ToolbarItem {
                    Button(viewModel.editingEnabled ? "button.done".localized : "button.edit".localized) {
                        viewModel.toggleEdit()
                    }
                }
            }
            
            // MARK: - Navigation
            .navigationDestination(for: GroupItem.self) { group in
                GroupView(viewModel: GroupViewModel(group: group, newRecipe: viewModel.newRecipe))
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeView(viewModel: RecipeViewModel(recipe: recipe))
            }
            
            // MARK: - Environment
            .environment(\.editMode, .constant(viewModel.editingEnabled ? EditMode.active : EditMode.inactive))
            
            // MARK: - Popups
            .popover(isPresented: $viewModel.addGroupSwitch) {
                NavigationStack {
                    NewGroupPopover(titleText: $viewModel.newGroupText,
                                    selectedRecipes: $viewModel.selectedRecipes,
                                    recipes: viewModel.getRecipes())
                    .editableToolbar(isEditing: $viewModel.editingEnabled,
                                     alternateLabel: "",
                                     saveAction: {self.viewModel.saveNewGroup()},
                                     cancelAction: {self.viewModel.cancelNewGroup()})
                }
            }
            .popover(isPresented: $viewModel.newRecipeSwitch) {
                if let recipe = viewModel.newRecipe?.dataEntity {
                    SelectGroupsView(viewModel: SelectGroupsViewModel(selectionAction: viewModel.selectionAction,
                                                                      cancelAction: viewModel.cancelAction,
                                                                      newRecipe: recipe))
                    .environment(\.managedObjectContext, self.viewContext)
                }
            }
            .alert("group.alert.delete".localized, isPresented: $viewModel.deleteGroupSwitch) {
                Button("button.delete".localized, role: .destructive) {
                    viewModel.deleteOnDeck()
                }
            }
        }
    }
}
