//
//  RecipeListThumbnail.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/15/26.
//

import SwiftUI

struct RecipeListThumbnail: View {
  let img: ImageData
  var body: some View {
    switch img {
    case .selected(let data):
      if let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 40, height: 40)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      } else {
        thumbnailPlaceholder
      }
    case .downloaded(let url):
      AsyncImage(url: url) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 40, height: 40)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      } placeholder: {
        ProgressView()
          .frame(width: 40, height: 40)
      }
    case .none:
      thumbnailPlaceholder
    }
  }

  private var thumbnailPlaceholder: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color(uiColor: .tertiarySystemFill))
      .frame(width: 40, height: 40)
      .overlay {
        Image(systemName: "fork.knife")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
  }
}
