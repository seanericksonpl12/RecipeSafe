//
//  SuggestionTile.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/15/24.
//

import SwiftUI

struct SuggestionTile: View {
    
    var title: String
    var geo: GeometryProxy
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
            .frame(width: (geo.size.width / 2.75), height: (geo.size.width / 2.75))
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(.systemGray4), lineWidth: 4)
                    .frame(width: (geo.size.width / 2.75), height: (geo.size.width / 2.75))
                    .background {
                        if let url = img {
                            CachedAsyncImage(url: url) { phase in
                                switch phase {
                                case.empty:
                                    ColorSet.color(color)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                case .failure(_):
                                    ColorSet.color(color)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                case .success(let img):
                                    img
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: (geo.size.width / 2.75), height: (geo.size.width / 2.75))
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        //.opacity(0.5)
                                        .zIndex(0)
                                @unknown default:
                                    ColorSet.color(color)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
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
