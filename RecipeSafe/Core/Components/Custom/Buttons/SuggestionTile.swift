//
//  SuggestionTile.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/15/24.
//

import SwiftUI
import NukeUI

struct SuggestionTile: View {
    
    var title: String
    var size: CGSize
    var img: URL?
    var color: Int16
    
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Spacer()
                HStack {
                    Text(title)
                        .fontWeight(.bold)
                        .font(.title3)
                        .padding(10)
                    Spacer()
                }
            }
            .frame(width: (size.width / 2.3), height: (size.width / 2.5))
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(.systemGray4), lineWidth: 4)
                    .frame(width: (size.width / 2.3), height: (size.width / 2.5))
                    .background {
                        if let url = img {
                            LazyImage(url: url) { state in
                                switch state.result {
                                case .none:
                                    ColorSet.color(color)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                case .failure(_):
                                    ColorSet.color(color)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                case .success(let img):
                                    Image(uiImage: img.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: (size.width / 2.3), height: (size.width / 2.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .zIndex(0)
                                }
                            }
                            .overlay {
                                ColorSet.color(color)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .opacity(0.75)
                            }
                        }
                    }
            }
        }.buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    Text("helo")
}
