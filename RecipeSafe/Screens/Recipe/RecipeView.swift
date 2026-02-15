import ComposableArchitecture
import SwiftUI

struct RecipeView: View {
  
  @Bindable var store: StoreOf<RecipeReducer>
  @State private var expandToolbar = false
  
  // MARK: - Body
  var body: some View {
    
    VStack {
      List {
        if !store.recipe.description.isEmpty || store.editingEnabled {
          EditableDescriptionView(
            recipe: $store.recipe,
            editingEnabled: store.editingEnabled,
            optionalDisplay: "create.display.desc".localized
          )
          .onTapGesture {
            hideKeyboard()
          }
        }
        if !store.recipe.ingredients.isEmpty || store.editingEnabled {
          EditableSectionView(
            list: $store.recipe.ingredients,
            isEditing: store.editingEnabled,
            headerText: "recipe.ingredients.title".localized,
            deleteAction: { store.send(.deleteIngredients($0)) },
            addAction: { store.send(.addIngredient) },
            optionalDisplay: "recipe.ingredients.new".localized
          )
        }
        if !store.recipe.instructions.isEmpty || store.editingEnabled {
          EditableSectionView(
            list: $store.recipe.instructions,
            isEditing: store.editingEnabled,
            headerText: "recipe.instructions.title".localized,
            numbered: true,
            deleteAction: { store.send(.deleteInstructions($0)) },
            addAction: { store.send(.addInstruction) },
            optionalDisplay: "recipe.instructions.new".localized
          )
        }
        
      }
      .alert($store.scope(state: \.alert, action: \.alert))
      .popover(item: $store.scope(state: \.destination?.selectGroups, action: \.destination.selectGroups)) { store in
        SelectGroupsViewTCA(store: store)
      }
      .environment(\.editMode, .constant(store.editingEnabled ? EditMode.active : EditMode.inactive))
      .navigationBarTitleDisplayMode(.inline)
//      .toolbar {
//        ToolbarItem {
//          if store.editingEnabled {
//            Button("button.save".localized) {
//              store.send(.saveChanges)
//            }
//          } else {
//            Menu {
//              Button("button.edit".localized) {
//                store.send(.binding(.set(\.editingEnabled, true)))
//              }
//              if store.recipe.dataEntity != nil {
//                Button("group.add".localized) {
//                  store.send(.showSelectGroups)
//                }
//                Button("button.delete".localized, role: .destructive) {
//                  store.send(.showAlert)
//                }
//              }
//            } label: {
//              Image(systemName: "ellipsis.circle")
//            }
//          }
//        }
//        if store.editingEnabled {
//          ToolbarItem {
//            Button("button.cancel".localized) {
//              store.send(.cancelChanges)
//            }
//          }
//        }
//      }
    }
    .navigationTitle(store.recipe.title)
    .toolbar(.hidden, for: .tabBar)
    .toolbar {
//        ToolbarItem(placement: .bottomBar) {
//            ToolbarSpacer() // Creates a gap
//        }
      if #available(iOS 26.0, *) {
        ToolbarSpacer(placement: .bottomBar)
      }
      if expandToolbar {
        ToolbarItem(placement: .bottomBar) {
          Button { } label: {
            Text("add")
          }
        }
        ToolbarItem(placement: .bottomBar) {
          Button { } label: {
            Text("Delete")
          }
        }
        
      } else {
        ToolbarItem(placement: .bottomBar) {
          Button {
            expandToolbar = true
          } label: {
            Text("Edit")
          }
        }
      }
//        ToolbarItem(placement: .bottomBar) {
//            ToolbarSpacer()
//        }
    }
//    .topBar {
//      HStack {
////        let image: ImageData = if let data = store.photoData { .selected(data) } else { .none }
////        PhotosPicker(selection: $store.photoPickerSelection.sending(\.photoPicked), matching: .images) {
////          IconImage(isEditing: true, img: image)
////        }
//        IconImage(isEditing: false, img: store.recipe.img)
//        TextField("", text: $store.recipe.title, prompt: Text("create.display.title".localized), axis: .vertical)
//          .font(.title)
//          .fontWeight(.heavy)
//          .padding()
//        Spacer()
//      }
//    }
    .pageLoad(.recipe)
    .keepScreenAlive()
  }
}

#if DEBUG
#Preview {
  NavigationStack {
    RecipeView(
      store: .init(
        initialState: RecipeState(
          recipe: Recipe(
            title: "My Recipe",
            description: "This is a some description of this recipe, .....",
            ingredients: ["1 egg", "2 lbs butter", "6 oz lime juice", "3 lbs turkey brains", "1 onion"],
            instructions: ["Boil the egg till hard", "Sauté the turkey brains", "Fry the onion"],
            img: .none,
            url: nil,
            prepTime: "20 min",
            cookTime: "45 min"
          ),
          editingEnabled: false
        ),
        reducer: RecipeReducer.init
      )
    )
  }
}
#endif
