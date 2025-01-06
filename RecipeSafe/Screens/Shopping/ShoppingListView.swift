//
//  ShoppingListView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 10/2/24.
//

import SwiftUI

extension ReferenceWritableKeyPath: @unchecked @retroactive Sendable {}

struct ShoppingListView: View {
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var recipeList: FetchedResults<RecipeItem>
    
    @Service var dataManager: DataManager!
    
    @State var isEditing: Bool = false

    @State private var showRecipes: Bool = true
    @State private var addRecipes: Bool = false
    @State private var recipesToAdd: [RecipeItem] = []
    @State private var filteredRecipeTitles: [String] = []
    @State private var ingredients: [IngredientGroup] = []

    var body: some View {
        NavigationStack {
            contentView
            .navigationTitle("Grocery List")
            .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
            .toolbar {
                EditableToolbar(
                    isEditing: $isEditing,
                    saveAction: saveChanges,
                    cancelAction: cancelChanges
                )
            }
            .sheet(isPresented: $addRecipes) {
                AddRecipePopover(
                    selectedRecipes: $recipesToAdd,
                    saveAction: saveAddedRecipes,
                    recipes: recipeList.filter { !$0.inShoppingList }
                )
            }
            .task {
                self.filteredRecipeTitles = recipeList.filter { $0.inShoppingList }.compactMap(\.title)
                self.ingredients = recipeList
                    .filter { $0.inShoppingList }
                    .flatMap { $0.ingredients?.array as? [Ingredient] ?? [] }
                    .map { IngredientGroup(ingredient: $0, selected: $0.selectedInShoppingList) }
            }
        }
    }
    
    
    var contentView: some View {
        GeometryReader { proxy in
            VStack {
                List {
                    if showRecipes {
//                        EditableSectionView(
//                            list: $filteredRecipeTitles,
//                            isEditing: $isEditing,
//                            headerText: "Recipes",
//                            deleteAction: { _ in },
//                            addAction: {}
//                        )
//                        .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
                        Section {
                            EditableGridView(isEditing: $isEditing, list: filteredRecipeTitles) { index, item in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(uiColor: UIColor.secondarySystemBackground))
                                    .stroke(Color(uiColor: UIColor.lightGray), lineWidth: 1)
                                    .frame(width: proxy.size.width / 4.0, height: 40)
                                    .overlay {
                                        Text(item)
                                    }
                            }
                            .padding([.leading, .trailing], -15)
                            .listRowBackground(Color.clear)
                        } header: {
                            Text("Recipes")
                        }
                    }
                    
                    CustomEditableSectionView(
                        list: $ingredients,
                        isEditing: $isEditing,
                        headerText: "Ingredients",
                        deleteAction: { _ in },
                        addAction: {}
                    ) {
                        customIngredientItem($0, $1)
                    }
                    .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
                }
                .scrollContentBackground(.hidden)
                
                HStack {
                    Button {
                        addRecipes = true
                    } label: {
                        Label("New Ingredient", systemImage: "plus.circle")
                    }
                    Spacer()
                }
                .padding()
            }
            .applyAppBackground(proxy: proxy)
        }
    }
    
    
    
    func customIngredientItem(_ index: Int, _ item: Binding<IngredientGroup>) -> some View {
        HStack {
            Button {
                withAnimation(.linear(duration: 0.1)) {
                    if let _ = ingredients.safeValue(at: index) {
                        ingredients[index].selected.toggle()
                    }
                    dataManager.updateIngredient(
                        ingredient: item.wrappedValue.ingredient,
                        isSelected: item.wrappedValue.selected
                    )
                }
            } label: {
                Image(systemName: item.wrappedValue.selected ? "checkmark.circle" : "circle")
            }
            
            CustomTextField(
                text: item.text,
                prompt: "Ingredient",
                promptAlign: .leading,
                staticLabel: "",
                font: .callout,
                fontWeight: .light,
                axis: .vertical
            )
            .disabled(!isEditing)
        }
    }
}

extension ShoppingListView {
    
    func save() {
        withAnimation {
            isEditing = false
        }
    }
    
    func saveAddedRecipes() {

        addRecipes = false
    }
    
    func saveChanges() {
        dataManager.updateIngredientsText(ingredients: self.ingredients)
        withAnimation { isEditing = false }
    }
    
    func cancelChanges() {
        for i in 0..<self.ingredients.count {
            if let text = ingredients[i].ingredient.value {
                ingredients[i].text = text
            }
        }
        Task { @MainActor in
            withAnimation { isEditing = false }
        }
    }
}

#Preview {
    ShoppingListView()
}
