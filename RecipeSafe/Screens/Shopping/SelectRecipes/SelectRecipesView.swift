
import ComposableArchitecture
import SwiftUI

struct SelectRecipesView: View {

  @Bindable var store: StoreOf<SelectRecipesReducer>

  var body: some View {
    NavigationStack {
      Group {
        if store.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if store.filteredRecipes.isEmpty {
          emptyState
        } else {
          recipeList
        }
      }
      .navigationTitle("Add Recipes")
      .navigationBarTitleDisplayMode(.inline)
      .searchable(text: $store.searchText, prompt: "Search recipes")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") {
            store.send(.cancel)
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            store.send(.done)
          }
          .fontWeight(.semibold)
          .disabled(store.selectedIds.isEmpty)
        }
      }
    }
    .task { store.send(.task) }
  }
}

// MARK: - Recipe List

private extension SelectRecipesView {
  var recipeList: some View {
    List(store.filteredRecipes) { recipe in
      recipeRow(recipe)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }
    .listStyle(.plain)
  }

  func recipeRow(_ recipe: Recipe) -> some View {
    let isSelected = store.selectedIds.contains(recipe.id)
    return Button {
      store.send(.recipeTapped(recipe), animation: .easeInOut(duration: 0.15))
    } label: {
      HStack(spacing: 12) {
        thumbnail(recipe.img)
        VStack(alignment: .leading, spacing: 2) {
          Text(recipe.title)
            .font(.body)
            .foregroundStyle(Color.Text.primary)
          Text("\(recipe.ingredients.count) ingredient\(recipe.ingredients.count == 1 ? "" : "s")")
            .font(.caption)
            .foregroundStyle(Color.Text.secondary)
        }
        Spacer()
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .font(.title3)
          .foregroundStyle(isSelected ? Color.accentColor : Color(uiColor: .tertiaryLabel))
      }
      .contentShape(Rectangle())
      .padding(.vertical, 4)
    }
    .buttonStyle(.plain)
  }

  func thumbnail(_ img: ImageData) -> some View {
    Group {
      switch img {
      case .selected(let data):
        if let uiImage = UIImage(data: data) {
          Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
        } else {
          placeholderThumbnail
        }
      case .downloaded(let url):
        AsyncImage(url: url) { image in
          image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
          ProgressView()
        }
      case .none:
        placeholderThumbnail
      }
    }
    .frame(width: 44, height: 44)
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }

  var placeholderThumbnail: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color(uiColor: .tertiarySystemFill))
      .overlay {
        Image(systemName: "fork.knife")
          .font(.body)
          .foregroundStyle(.secondary)
      }
  }

  var emptyState: some View {
    VStack(spacing: 8) {
      Image(systemName: "fork.knife.circle")
        .font(.system(size: 44))
        .foregroundStyle(.secondary)
      Text(store.searchText.isEmpty ? "No recipes available" : "No results")
        .font(.headline)
        .foregroundStyle(Color.Text.primary)
      Text(store.searchText.isEmpty ? "Add some recipes first." : "Try a different search term.")
        .font(.subheadline)
        .foregroundStyle(Color.Text.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#if DEBUG
#Preview {
  SelectRecipesView(store: .init(
    initialState: SelectRecipesReducer.State(),
    reducer: SelectRecipesReducer.init
  ))
}
#endif
