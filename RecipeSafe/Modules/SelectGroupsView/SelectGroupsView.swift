//
//  SelectGroupsPopover.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/14/23.
//

import SwiftUI

struct SelectGroupsView: View {
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var groups: FetchedResults<GroupItem>
    
    // MARK: - ViewModel
    @StateObject var viewModel: SelectGroupsViewModel
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack {
                    HStack {
                        Text("group.new.add".localized)
                            .font(.title)
                            .fontWeight(.heavy)
                            .padding()
                        Spacer()
                        Button("button.cancel".localized) {
                            viewModel.cancelAction()
                        }
                        .padding()
                    }
                    // MARK: - Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: (geo.size.width / 2.75)))]) {
                            InsertGridButton(insertAction: { viewModel.addNewGroup() }, width: (geo.size.width / 2.75), height: (geo.size.width / 2.75))
                            ForEach(groups) { item in
                                GridButton(isEditing: $viewModel.notEditBinding, geoProxy: geo, group: item, deleteAction: {})
                                    .onTapGesture {
                                        viewModel.selectionAction(item)
                                    }
                            }
                        }
                    }
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
                .popover(isPresented: $viewModel.newGroupSwitch) {
                    NavigationStack {
                        NewGroupPopover(titleText: $viewModel.newGroupText,
                                        selectedRecipes: $viewModel.selectedRecipes,
                                        recipes: [viewModel.newRecipe],
                                        allowSelection: false, color: ColorSet.color(Int(viewModel.newGroupColor ?? 0)))
                        .editableToolbar(isEditing: $viewModel.editBinding,
                                         alternateLabel: "",
                                         saveAction: { self.viewModel.saveNewGroup()},
                                         cancelAction: {self.viewModel.cancelNewGroup()})
                    }
                }
            }
        }
    }
}
