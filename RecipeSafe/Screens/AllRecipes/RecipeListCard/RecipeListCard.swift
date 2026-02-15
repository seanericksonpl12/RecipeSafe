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
          .foregroundStyle(Color.black)
          .lineLimit(1)

        // TODO: Add category property to Recipe model
        // Text(recipe.category)
        //   .font(.caption)
        //   .foregroundStyle(.secondary)
      }

      Spacer()

      // TODO: Add isFavorite property to Recipe model
      // if recipe.isFavorite {
      //   Image(systemName: "heart.fill")
      //     .font(.caption)
      //     .foregroundStyle(.red)
      // }

      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(.tertiary)
    }
    .padding(8)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 15))
  }
}

#if DEBUG
#Preview {
  RecipeListCard(recipe: Recipe.recipeMockSpaghetti)
}
#endif
