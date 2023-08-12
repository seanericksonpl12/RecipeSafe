//
//  GroupView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import SwiftUI

struct GroupGridView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var groups: FetchedResults<GroupItem>
    
    @StateObject private var viewModel: GroupGridViewModel = GroupGridViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                if groups.isEmpty && !viewModel.editingEnabled {
                    EmptyListView()
                        .frame(width: geo.size.width, height: geo.size.height)
                }
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: (geo.size.width / 3)))]) {
                        if viewModel.editingEnabled {
                            InsertGridButton(insertAction: { viewModel.addGroup() },
                                             width: (geo.size.width / 3),
                                             height: (geo.size.width / 3))
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
                }
                .scrollDisabled(groups.isEmpty && !viewModel.editingEnabled)
                .scrollContentBackground(.hidden)
                .background {
                    Image("logo-background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing)
                        .ignoresSafeArea(.all)
                        .opacity(0.3)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(viewModel.editingEnabled ? "button.done".localized : "button.edit".localized) {
                        viewModel.toggleEdit()
                    }
                }
            }
            .environment(\.editMode, .constant(viewModel.editingEnabled ? EditMode.active : EditMode.inactive))
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
            .alert("group.alert.delete".localized, isPresented: $viewModel.deleteGroupSwitch) {
                Button("button.delete".localized, role: .destructive) {
                    if let item = viewModel.onDeckToDelete {
                        viewModel.deleteGroup(item)
                    }
                }
            }
        }
    }
}

struct GroupGridView_Previews: PreviewProvider {
    static var previews: some View {
        GroupGridView()
    }
}
