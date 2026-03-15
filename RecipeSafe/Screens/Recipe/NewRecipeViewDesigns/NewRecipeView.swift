import ComposableArchitecture
import SwiftUI

struct NewRecipeView: View {
  
  @Bindable var store: StoreOf<RecipeReducer>
  @State private var selectedTab: RecipeTab = .ingredients
  @State private var showNavTitle = false
  @State private var backgroundImageOpacity = 1.0
  
  enum RecipeTab: String, CaseIterable {
    case ingredients = "Ingredients"
    case instructions = "Instructions"
  }
  
  private let imageHeight: CGFloat = 250
  
  // MARK: - Body
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
        
        // MARK: Header
        NewRecipeHeader(recipe: store.recipe)
          .padding(.horizontal)
          .padding(.top, 16)
          .padding(.bottom, 8)
          .background(.background)
        
        // MARK: Pinned Segment + Content
        Section {
          contentList
            .padding(.horizontal)
            .gesture(
              DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                  if value.translation.width < -30 && selectedTab == .ingredients {
                    selectedTab = .instructions
                  } else if value.translation.width > 30 && selectedTab == .instructions {
                    selectedTab = .ingredients
                  }
                }
            )
        } header: {
          segmentedControl
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }
    .onScrollGeometryChange(for: Bool.self) { geo in
      geo.contentOffset.y > 40
    } action: { _, isPastThreshold in
      showNavTitle = isPastThreshold
    }
    .onScrollGeometryChange(for: CGFloat.self) { geo in
      geo.contentOffset.y
    } action: { _, offset in
      backgroundImageOpacity = min(1, (1.0 - ((offset + 50) / 100.0)))
    }
    .contentMargins(.bottom, 50, for: .scrollContent)
    .navigationTitle(showNavTitle ? store.recipe.title : "")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.hidden, for: .navigationBar)
    .toolbar(.hidden, for: .tabBar)
    .toolbar { toolBarContent }
    .background(alignment: .top) {
      RecipeHeaderImage(image: store.recipe.img)
        .frame(maxHeight: 250)
        .ignoresSafeArea(edges: .top)
        .opacity(backgroundImageOpacity)
    }
    .animation(.easeInOut, value: selectedTab)
    .alert($store.scope(state: \.alert, action: \.alert))
    .sheet(item: $store.scope(
      state: \.destination?.selectCategories,
      action: \.destination.selectCategories
    )) { store in
      SelectCategoriesView(store: store)
        .presentationDetents([.medium])
    }
  }
}

// MARK: - Segmented Control
extension NewRecipeView {
  private var segmentedControl: some View {
    Picker("", selection: $selectedTab) {
      ForEach(RecipeTab.allCases, id: \.self) { tab in
        Text(tab.rawValue).tag(tab)
      }
    }
    .pickerStyle(.segmented)
    .background(.background, in: .capsule)
    .padding(.horizontal)
    .padding(.vertical, 8)
  }
}

// MARK: - Content List
extension NewRecipeView {
  @ViewBuilder
  private var contentList: some View {
    switch selectedTab {
    case .ingredients:
      ForEach(Array(store.recipe.ingredients.enumerated()), id: \.element.id) { index, item in
        let isChecked = store.checkedIngredients[item.id] == true
        HStack(spacing: 12) {
          Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .foregroundStyle(Color.Icon.default)
            .font(.title3)
          Text(item.value)
            .font(.subheadline)
            .strikethrough(isChecked)
            .foregroundStyle(isChecked ? Color.Text.tertiary : Color.Text.primary)
          Spacer()
        }
        .padding(12)
        .background(Color.Card.background, in: RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          store.send(.toggleIngredientChecked(item))
        }
      }
      .padding(.top, 4)
      .transition(.move(edge: .leading))
    case .instructions:
      ForEach(Array(store.recipe.instructions.enumerated()), id: \.element.id) { index, item in
        HStack(alignment: .top, spacing: 12) {
          Text("\(index + 1)")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.Text.secondary)
            .frame(width: 22, height: 22)
            .background(Color.Card.backgroundSecondary, in: Circle())
          Text(item.value)
            .font(.subheadline)
            .foregroundStyle(Color.Text.primary)
          Spacer()
        }
        .padding(12)
        .background(Color.Card.background, in: RoundedRectangle(cornerRadius: 10))
      }
      .padding(.top, 4)
      .transition(.move(edge: .trailing))
    }
  }
}

private extension NewRecipeView {
  @ToolbarContentBuilder
  var toolBarContent: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button("Favorite", systemImage: store.recipe.isFavorite ? "heart.fill" : "heart") {
        store.send(.favoriteRecipe)
      }
      .foregroundStyle(Color.red)
    }
    ToolbarItem(placement: .topBarTrailing) {
      Menu("Options", systemImage: "ellipsis") {
        Button("Add Tag", systemImage: "tag") {
          store.send(.showSelectCategories)
        }
        Button("Edit", systemImage: "slider.horizontal.3") {
          
        }
        Button("Delete", systemImage: "trash", role: .destructive) {
          store.send(.showAlert)
        }
      }
    }
  }
}

// MARK: - Preview
#if DEBUG
#Preview {
  NavigationStack {
    NewRecipeView(
      store: .init(
        initialState: RecipeState(
          recipe: .recipeMockSpaghetti,
          editingEnabled: false
        ),
        reducer: RecipeReducer.init
      )
    )
  }
}
#endif
