//
//  GroupHeaderImage.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/17/23.
//

import SwiftUI
import NukeUI

struct GroupHeaderImage: View {
    
    @Binding var group: GroupModel
    
    var body: some View {
        if let url = group.imgUrl {
            LazyImage(url: url) { state in
                switch state.result {
                case .none:
                    ColorSet.color(group.dataEntity.color)
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.75)
                        .allowsHitTesting(false)
                        .zIndex(0)
                case .failure(_):
                    ColorSet.color(group.dataEntity.color)
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.75)
                        .allowsHitTesting(false)
                        .zIndex(0)
                case .success(let img):
                    Image(uiImage: img.image)
                        .resizable()
                        .scaledToFill()
                        .opacity(0.85)
                        .allowsHitTesting(false)
                        .zIndex(0)
                }
            }
        }
        else {
            ColorSet.color(group.dataEntity.color)
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.75)
                .allowsHitTesting(false)
                .zIndex(0)
        }
    }
}
