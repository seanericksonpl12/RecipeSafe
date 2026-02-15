//import ComposableArchitecture
//import SwiftUI
//import CoreData
//
//extension ReferenceWritableKeyPath: @unchecked @retroactive Sendable {}
//
//struct ShoppingListViewTCA: View {
//  
//  @Bindable var store: StoreOf<ShoppingListReducer>
//  
//  @Environment(\.keyboardShowing) var isKeyboardShowing
//  @FocusState var itemFocus: ShoppingListModel?
//  
//  init(store: StoreOf<ShoppingListReducer>) {
//    self.store = store
//  }
//  
//  var body: some View {
//    NavigationStack {
//      contentView
//        .navigationTitle("Grocery List")
//        .environment(\.editMode, .constant(store.isEditing ? EditMode.active : EditMode.inactive))
//        .toolbar { toolbar }
//        .sheet(item: $store.scope(state: \.destination?.addRecipe, action: \.destination.addRecipe)) { store in
//          AddRecipeViewTCA(store: store)
//        }
//        .alert($store.scope(state: \.alert, action: \.alert))
//        .onChange(of: store.isEditing) { _, value in
//          store.send(.toggleEdit)
//        }
//        .task {
//          store.send(.task)
//        }
//        .pageLoad(.shoppingList)
//    }
//    .emptyModifier(isHidden: store.shoppingList.isEmpty, description: "Add some ingredients or a new recipe to get started!")
//  }
//  
//  @ToolbarContentBuilder
//  var toolbar: some ToolbarContent {
//    if store.isEditing {
//      ToolbarItem {
//        Button {
//          store.send(.saveChanges)
//        } label: {
//          Text("button.save".localized)
//        }
//      }
//      ToolbarItem {
//        Button("button.cancel".localized, role: .destructive) {
//          store.send(.cancelChanges)
//        }
//      }
//    } else {
//      ToolbarItem {
//        Menu {
//          Button("button.edit".localized) {
//            store.send(.toggleEdit)
//          }
//          Button("Reset Selected") {
//            store.send(.resetSelected)
//          }
//          Button("Clear", role: .destructive) {
//            store.send(.showClearAlert)
//          }
//        } label: {
//          Image(systemName: "ellipsis.circle")
//            .frame(width: 40, height: 40)
//            .contentShape(Rectangle())
//        }
//      }
//    }
//  }
//
//  var contentView: some View {
//    ScrollViewReader { scrollProxy in
//      VStack {
//        List {
//          if store.showRecipes {
//            CustomEditableSectionView(
//              list: store.filteredRecipes,
//              isEditing: $store.isEditing,
//              headerText: "Recipes",
//              deleteAction: { store.send(.deleteRecipe($0)) },
//              addAction: { store.send(.addRecipes) }
//            ) {
//              customRecipeItem($0, $1)
//            }
//            .moveDisabled(true)
//            .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
//          }
//          Section {
//            ForEach(store.shoppingList) { item in
//              HStack {
//                Button {
//                  store.send(.toggleSelected(item))
//                } label: {
//                  Image(systemName: item.selected ? "checkmark.circle.fill" : "circle")
//                }
//                .disabled(isKeyboardShowing)
//                
//                CustomTextField(
//                  text: .init(
//                    get: { item.value },
//                    set: { store.send(.ingredientValueChanged(item, $0)) }
//                  ),
//                  prompt: "Ingredient",
//                  promptAlign: .leading,
//                  staticLabel: "",
//                  font: .callout,
//                  fontWeight: .light,
//                  axis: .vertical,
//                  lineLimit: 1
//                ) { _ in
//                  withAnimation {
//                    scrollProxy.scrollTo(999, anchor: .bottom)
//                  }
//                  store.send(.ingredientSubmitted(item))
//                }
//                .focused($itemFocus, equals: item)
//                .disabled(!store.isEditing)
//              }
//            }
//            .onDelete { store.send(.deleteIngredient($0)) }
//            .moveDisabled(true)
//          } header: {
//            if !store.shoppingList.isEmpty {
//              HStack {
//                Text("Ingredients")
//              }
//            }
//          }
//          .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
//          Rectangle().id(999).frame(height: 0).foregroundStyle(.clear)
//            .listRowBackground(Color(uiColor: .clear))
//        }
//        .scrollContentBackground(.hidden)
//        
//        if !isKeyboardShowing {
//          HStack {
//            Button {
//              scrollProxy.scrollTo(999, anchor: .bottom)
//              store.send(.addNewIngredient)
//              Task { @MainActor in
//                itemFocus = store.shoppingList.last
//              }
//            } label: {
//              Label("New Ingredient", systemImage: "plus.circle")
//            }
//            Spacer()
//          }
//          .padding()
//        } else {
//          HStack {
//            Button {
//              if let last = store.shoppingList.last {
//                store.send(.deleteIngredient(IndexSet([store.shoppingList.count - 1])))
//              }
//              itemFocus = nil
//            } label: {
//              Text("Cancel")
//            }
//            Spacer()
//          }
//          .padding()
//        }
//      }
//    }
//  }
//  
//  @ViewBuilder
//  func customRecipeItem(_ index: Int, _ item: Recipe) -> some View {
//    NavigationLink(item.title) {
//      RecipeViewTCA(store: Store(initialState: RecipeState(recipe: item, editingEnabled: false)) {
//        RecipeReducer()
//      })
//    }
//  }
//}
