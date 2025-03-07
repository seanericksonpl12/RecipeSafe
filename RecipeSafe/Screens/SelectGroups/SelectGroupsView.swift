//
//  SelectGroupsPopover.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/14/23.
//

import SwiftUI

struct SelectGroupsView: View {
    
    // MARK: - Environment
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var groups: FetchedResults<GroupItem>
    
    @Environment(\.services.groupData) var groupDataService
    
    @State var editBinding: Bool = true
    @State var notEditBinding: Bool = false
    @State var newGroupSwitch: Bool = false
    @State var newGroupText: String = ""
    @State var selectedRecipes: [RecipeItem] = []
    @State var newGroupColor: Int16?
    
    let selectionAction: (GroupItem) -> Void
    let cancelAction: () -> Void
    let newRecipe: RecipeItem
    
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
                            cancelAction()
                        }
                        .padding()
                    }
                    // MARK: - Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: (geo.size.width / 2.75)))]) {
                            InsertGridButton(insertAction: { addNewGroup() }, width: (geo.size.width / 2.75), height: (geo.size.width / 2.75))
                            ForEach(groups) { item in
                                GridButton(isEditing: $notEditBinding, geoProxy: geo, group: item, deleteAction: {})
                                    .onTapGesture {
                                        selectionAction(item)
                                    }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .popover(isPresented: $newGroupSwitch) {
                    NavigationStack {
                        NewGroupPopover(
                            titleText: $newGroupText,
                            selectedRecipes: $selectedRecipes,
                            recipes: [newRecipe],
                            allowSelection: false, color: ColorSet.color(newGroupColor)
                        )
                        .editableToolbar(
                            isEditing: $editBinding,
                            save: { saveNewGroup() },
                            cancel: { cancelNewGroup() }
                        )
                    }
                }
            }
        }
    }
}

extension SelectGroupsView {
    
    func addNewGroup() {
        self.newGroupColor = try? groupDataService.getNewColor()
        self.newGroupSwitch.toggle()
    }
    
    func saveNewGroup() {
        let newGroup = (title: newGroupText, recipes: selectedRecipes, color: self.newGroupColor)
        try? groupDataService.create(newGroup)
        newGroupSwitch = false
        let groups: [GroupItem] = groups.filter { group in
            if let recipes = group.recipes?.array as? [RecipeItem] {
                return group.title == self.newGroupText && recipes == self.selectedRecipes
            }
            return false
        }
        newGroupText = ""
        newGroupColor = nil
        guard let group = groups.first else { return }
        selectionAction(group)
    }
    
    func cancelNewGroup() {
        self.newGroupText = ""
        self.newGroupSwitch = false
        self.newGroupColor = nil
    }
}
