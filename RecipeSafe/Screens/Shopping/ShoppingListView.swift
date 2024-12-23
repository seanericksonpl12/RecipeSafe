//
//  ShoppingListView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 10/2/24.
//

import SwiftUI

struct ShoppingListView: View {
    
    @Service var dataManager: DataManager!
    
    @State var isEditing: Bool = false
    @State var groceries: [ShoppingListItem] = []
    @State var recipes: [Recipe] = []
    @State private var backupGroceries: [ShoppingListItem] = []
    @State private var backupRecipes: [Recipe] = []
    @State private var showRecipes: Bool = true
    
    var body: some View {
        NavigationStack {
            Group {
                if groceries.isEmpty && !isEditing {
                    EmptyListView(description: "")
                } else {
                    listView
                }
            }
            .navigationTitle("Grocery List")
            .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
            .toolbar {
                if isEditing {
                    EditableToolbar(
                        isEditing: $isEditing,
                        saveAction: save,
                        cancelAction: cancel
                    )
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            print("add shit")
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .task {
                self.groceries = dataManager.getShoppingList()
                self.recipes = dataManager.getShoppingListRecipes()
                self.backupGroceries = groceries
                self.backupRecipes = recipes
            }
        }
    }
    
    @MainActor
    var listView: some View {
        
        List {
            if showRecipes {
                Section {
                    ForEach(recipes) {
                        Text($0.title)
                    }.onDelete {
                        recipes.remove(atOffsets: $0)
                        withAnimation {
                            groceries = dataManager.updateShoppingRecipes(recipes)
                        }
                    }
                } header: {
                    Text("Recipes")
                }
            }
            Section {
                ForEach($groceries) { item in
                    HStack {
                        Group {
                            Button {
                                withAnimation(.linear(duration: 0.1)) {
                                    item.selected.wrappedValue.toggle()
                                }
                                dataManager.saveShoppingList(list: groceries)
                            } label: {
                                Image(systemName: item.selected.wrappedValue ? "checkmark.circle" : "circle")
                            }
                            .padding([.leading, .trailing])
                            
                            CustomTextField(
                                text: item.ingredient,
                                prompt: "Ingredient",
                                promptAlign: .leading,
                                staticLabel: "",
                                font: .callout,
                                fontWeight: .light,
                                axis: .vertical
                            )
                            
                            .disabled(!isEditing)
                            .padding(.trailing)
                            
                        }
                        .onLongPressGesture {
                            print("long press")
                        }
                    }
                    //.onTapGesture {}
                    
                    
                }
                .onDelete {
                    groceries.remove(atOffsets: $0)
                }
            } header: {
                Text("Ingredients")
            }
        }
        
    }
}

extension ShoppingListView {
    
    func save() {
        withAnimation {
            isEditing = false
        }
    }
    
    func cancel() {
        withAnimation {
            groceries = backupGroceries
            recipes = backupRecipes
            isEditing = false
        }
    }
    
    func fetchRecipes() {
        print("self recipe count: \(self.recipes.count)")
    }
}

#Preview {
    ShoppingListView()
}
