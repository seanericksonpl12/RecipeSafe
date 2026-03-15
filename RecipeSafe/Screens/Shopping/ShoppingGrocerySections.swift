import ComposableArchitecture
import SwiftUI

struct ShoppingGrocerySections: View {

  @Bindable var store: StoreOf<ShoppingListReducer>
  @State private var newIngredientText: String = ""
  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(spacing: 14) {
      if store.isEditing {
        HStack {
          AddItemChipButton(label: "Add Ingredient") {
            store.addingNewIngredient = true
            isFocused = true
          }
          Spacer()
        }
        if store.addingNewIngredient {
          newIngredientRow
        }
      }
      ForEach(store.groupedItems, id: \.category) { group in
        grocerySection(group.category, items: group.items)
      }
    }
    .padding(.horizontal)
    .padding(.top, 12)
  }
}

// MARK: - New Ingredient Row

private extension ShoppingGrocerySections {
  var newIngredientRow: some View {
    HStack(spacing: 12) {
      Image(systemName: "plus.circle.fill")
        .font(.system(size: 22))
        .foregroundStyle(.blue)
      TextField("Add ingredient...", text: $newIngredientText)
        .font(.body)
        .focused($isFocused)
        .onSubmit(submitIngredient)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 11)
    .background(Color.Card.background.opacity(0.75), in: RoundedRectangle(cornerRadius: 14))
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .strokeBorder(Color.white.opacity(0.6), lineWidth: 0.5)
    )
//    .onAppear { isFocused = true }
  }

  func submitIngredient() {
    store.send(.addFreeformItem(newIngredientText))
    newIngredientText = ""
//    isFocused = true
  }
}

// MARK: - Grocery Section

private extension ShoppingGrocerySections {
  func grocerySection(_ category: GroceryCategory, items: [ShoppingListModel]) -> some View {
    let isCollapsed = store.collapsedSections.contains(category)
    let sectionChecked = items.filter(\.selected).count

    return VStack(alignment: .leading, spacing: 8) {
      Button {
        store.send(.toggleSection(category), animation: .snappy)
      } label: {
        HStack {
          HStack(spacing: 8) {
            Text(category.displayName)
              .font(.headline)
              .foregroundStyle(Color.Text.primary)
            Text("\(sectionChecked)/\(items.count)")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundStyle(
                sectionChecked == items.count ? Color.green : Color.Text.secondary
              )
          }
          Spacer()
          Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.Text.secondary)
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if !isCollapsed {
        VStack(spacing: 0) {
          ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            ingredientRow(item)
            if index < items.count - 1 {
              Divider()
                .padding(.leading, 48)
            }
          }
        }
        .background(Color.Card.background.opacity(0.75), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
          RoundedRectangle(cornerRadius: 14)
            .strokeBorder(Color.white.opacity(0.6), lineWidth: 0.5)
        )
      }
    }
  }
}

// MARK: - Ingredient Row

private extension ShoppingGrocerySections {
  func ingredientRow(_ item: ShoppingListModel) -> some View {
    HStack(spacing: 0) {
      if store.isEditing {
        Button {
          store.send(.deleteItem(item), animation: .default)
        } label: {
          Image(systemName: "minus.circle.fill")
            .font(.system(size: 22))
            .foregroundStyle(.white, Color.red)
            .padding(.leading, 14)
            .padding(.trailing, 10)
        }
        .transition(.move(edge: .leading).combined(with: .opacity))
      }

      Button {
        if !store.isEditing {
          store.send(.toggleItemSelected(item), animation: .easeInOut(duration: 0.15))
        }
      } label: {
        HStack(spacing: 12) {
          RoundedRectangle(cornerRadius: 6)
            .fill(item.selected ? Color.green : Color.clear)
            .overlay {
              if item.selected {
                Image(systemName: "checkmark")
                  .font(.caption.weight(.bold))
                  .foregroundStyle(.white)
              }
            }
            .overlay {
              if !item.selected {
                RoundedRectangle(cornerRadius: 6)
                  .strokeBorder(Color(uiColor: .tertiaryLabel), lineWidth: 2)
              }
            }
            .frame(width: 22, height: 22)
            .opacity(store.isEditing ? 0.4 : 1)

          VStack(alignment: .leading, spacing: 1) {
            Text(item.value)
              .font(.body)
              .foregroundStyle(item.selected ? Color.Text.secondary : Color.Text.primary)
              .strikethrough(item.selected)
            Text(item.category.displayName)
              .font(.subheadline)
              .foregroundStyle(Color.Text.secondary)
          }

          Spacer()
        }
        .padding(.leading, store.isEditing ? 0 : 14)
        .padding(.trailing, 14)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    }
  }
}
