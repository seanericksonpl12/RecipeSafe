import SwiftUI

struct RecipeListCard: View {
  let recipe: Recipe
  
  var body: some View {
    HStack(spacing: 12) {
      // Thumbnail
      RecipeListThumbnail(img: recipe.img)

      // Title + Category
      VStack(alignment: .leading, spacing: 2) {
        Text(recipe.title)
          .font(.body)
          .foregroundStyle(Color.Text.primary)
          .lineLimit(1)
      
        if !recipe.tags.isEmpty {
          HStack(spacing: 8) {
            ForEach(recipe.tags) { tag in
              Text(tag.label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.Text.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(ColorSet.color(tag.color).opacity(0.5), in: Capsule())
            }
          }
          .padding(.vertical, 6)
        }
      }

      Spacer()

      if recipe.isFavorite {
        Image(systemName: "heart.fill")
          .foregroundStyle(Color.red)
      }

      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(Color.Icon.default)
    }
    .padding(8)
    .background(Color.Card.background, in: RoundedRectangle(cornerRadius: 15))
  }
}

#if DEBUG
#Preview {
  RecipeListCard(recipe: Recipe.recipeMockSpaghetti)
}
#endif
