import ComposableArchitecture
import SwiftUI

struct ShoppingRecipesSection: View {

  let store: StoreOf<ShoppingListReducer>

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Button {
        store.send(.toggleRecipesExpanded, animation: .snappy)
      } label: {
        HStack {
          Text("Recipes (\(store.recipes.count))")
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(Color.Text.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
          Spacer()
          Image(systemName: store.recipesExpanded ? "chevron.up" : "chevron.down")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.Text.secondary)
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if store.recipesExpanded {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(store.recipes) { recipe in
              Button {
                store.send(.recipeTapped(recipe))
              } label: {
                recipeChip(recipe)
              }
            }
            AddItemChipButton(label: "Add Recipe") {
              store.send(.addRecipeTapped)
            }
          }
        }
      }
    }
    .padding(.horizontal)
    .padding(.top, 16)
  }
}

// MARK: - Recipe Chips

private extension ShoppingRecipesSection {
  func recipeChip(_ recipe: Recipe) -> some View {
    HStack(spacing: 8) {
      recipeChipThumbnail(recipe.img)
      VStack(alignment: .leading, spacing: 1) {
        Text(recipe.title)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(Color.Text.primary)
          .lineLimit(1)
          .frame(maxWidth: 120, alignment: .leading)
        Text("\(recipe.ingredients.count) items")
          .font(.caption2)
          .foregroundStyle(Color.Text.secondary)
      }
    }
    .padding(.leading, 6)
    .padding(.trailing, 10)
    .padding(.vertical, 6)
    .background(Color.Card.background.opacity(0.75), in: RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .strokeBorder(Color.white.opacity(0.6), lineWidth: 0.5)
    )
    .overlay(alignment: .topTrailing) {
      if store.isEditing {
        Button {
          store.send(.deleteRecipe(recipe), animation: .default)
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 18))
            .foregroundStyle(.white, Color.red)
        }
        .offset(x: 8, y: -8)
      }
    }
    .padding(.top, store.isEditing ? 8 : 0)
  }

  func recipeChipThumbnail(_ img: ImageData) -> some View {
    Group {
      switch img {
      case .selected(let data):
        if let uiImage = UIImage(data: data) {
          Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
        } else {
          chipPlaceholder
        }
      case .downloaded(let url):
        AsyncImage(url: url) { image in
          image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
          ProgressView()
        }
      case .none:
        chipPlaceholder
      }
    }
    .frame(width: 32, height: 32)
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }

  var chipPlaceholder: some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(Color(uiColor: .tertiarySystemFill))
      .overlay {
        Image(systemName: "fork.knife")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
  }
}
