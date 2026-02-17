import ComposableArchitecture
import PhotosUI
import SwiftUI

struct CustomRecipeView: View {
  
  @Bindable var store: StoreOf<CustomRecipeReducer>
  @FocusState private var ingredientFocusState
  @FocusState private var instructionFocusState
  
  // MARK: - Body
  var body: some View {
    NavigationStack {
      content
        .environment(\.editMode, .constant(.active))
        .topBar {
          HStack {
            let image: ImageData = if let data = store.photoData { .selected(data) } else { .none }
            PhotosPicker(selection: $store.photoPickerSelection.sending(\.photoPicked), matching: .images) {
              IconImage(isEditing: true, img: image)
            }
            TextField("", text: $store.recipe.title, prompt: Text("create.display.title".localized), axis: .vertical)
              .font(.title)
              .fontWeight(.heavy)
              .padding()
            Spacer()
          }
        }
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            HStack {
              Button {
                store.send(.save)
              } label: {
                Text("Save")
              }
              Button {
                store.send(.dismiss)
              } label: {
                Text("Cancel")
              }
            }
          }
        }
    }
    .pageLoad(.recipe)
    .keepScreenAlive()
  }
}

extension CustomRecipeView {
  var content: some View {
    VStack(spacing: 0) {
      List {
        EditableDescriptionView(
          recipe: $store.recipe,
          editingEnabled: true,
          optionalDisplay: "create.display.desc".localized
        )
        Section {
          if store.recipe.ingredients.isEmpty {
            HStack {
              Spacer()
              Button {
                store.send(.addIngredient)
                ingredientFocusState = true
              } label: {
                Image(systemName: "plus.app")
                  .foregroundStyle(.secondary)
              }
              Spacer()
            }
          }
          ForEach(Array(store.recipe.ingredients.enumerated()), id: \.element.id) { index, item in
            let binding = $store.recipe.ingredients[index]
            HStack {
              TextField(item.value.isEmpty ? "optionalDisplay" : "", text: binding.value, axis: .horizontal)
                .onSubmit {
                  if !item.value.trimmingWhitespace().isEmpty {
                    store.send(.addIngredient)
                    Task { ingredientFocusState = true }
                  } else {
                    store.send(.removeIngredients(.init(integer: index)), animation: .bouncy)
                  }
                }
                .onChange(of: ingredientFocusState) { oldValue, newValue in
                  if oldValue, !newValue, item.value.trimmingWhitespace().isEmpty {
                    store.send(.removeIngredients(.init(integer: index)), animation: .bouncy)
                  }
                }
                .focused($ingredientFocusState, equals: index == store.recipe.ingredients.count - 1 && item.value.isEmpty)
                .font(.callout)
            }
          }
          .onDelete { store.send(.removeIngredients($0)) }
          .onMove { source, destination in
            store.send(.moveIngredients(from: source, to: destination))
          }
          
        } header: {
          Text("Ingredients")
            .font(.callout)
            .fontWeight(.heavy)
        }
        .padding(.top, 8)
        
        Section {
          if store.recipe.instructions.isEmpty {
            HStack {
              Spacer()
              Button {
                store.send(.addInstruction)
                instructionFocusState = true
              } label: {
                Image(systemName: "plus.app")
                  .foregroundStyle(.secondary)
              }
              Spacer()
            }
          }
          ForEach(Array(store.recipe.instructions.enumerated()), id: \.element.id) { index, item in
            let binding = $store.recipe.instructions[index]
            HStack {
              VStack {
                Text((index + 1).formatted())
                  .font(.caption)
                  .fontWeight(.bold)
                Spacer()
              }
              TextField(item.value.isEmpty ? "optionalDisplay" : "", text: binding.value, axis: .horizontal)
                .onSubmit {
                  if !item.value.trimmingWhitespace().isEmpty {
                    store.send(.addInstruction)
                    Task { instructionFocusState = true }
                  } else {
                    store.send(.removeInstructions(.init(integer: index)))
                  }
                }
                .focused($instructionFocusState, equals: index == store.recipe.instructions.count - 1 && item.value.isEmpty)
                .font(.callout)
            }
          }
          .onDelete { store.send(.removeInstructions($0)) }
          .onMove { source, destination in
            store.send(.moveInstructions(from: source, to: destination))
          }
        } header: {
          Text("Instruction")
            .font(.callout)
            .fontWeight(.heavy)
        }
        .padding(.top, 8)
      }
    }
    .popover(item: $store.scope(state: \.destination, action: \.destination)) { store in
      SelectGroupsViewTCA(store: store)
    }
  }
}

#if DEBUG
#Preview {
  CustomRecipeView(
    store: .init(
      initialState: CustomRecipeState(
        recipe: .recipeMockChicken
      ),
      reducer: CustomRecipeReducer.init
    )
  )
}
#endif
