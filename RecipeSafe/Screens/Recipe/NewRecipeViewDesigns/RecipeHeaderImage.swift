import SwiftUI

struct RecipeHeaderImage: View {
  let image: ImageData

  var body: some View {
    switch image {
    case .selected(let data):
      if let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(contentMode: .fill)
      } else {
        Color(.secondarySystemBackground)
      }
    case .downloaded(let url):
      AsyncImage(url: url) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
      } placeholder: {
        Color(.secondarySystemBackground)
      }
    case .none:
      Color(.secondarySystemBackground)
    }
  }
}
