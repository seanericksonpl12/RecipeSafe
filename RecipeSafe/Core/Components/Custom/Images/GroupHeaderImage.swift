//
//  GroupHeaderImage.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/17/23.
//

import SwiftUI
import NukeUI
import Dependencies

struct GroupHeaderImage: View {
    
    @Binding var group: GroupModel
    @Dependency(\.coreDataService) var coreDataService
    
    private var groupColor: Int16 {
        let groupManager = GroupManager()
        return groupManager.getColor(for: group.dataEntityID) ?? 1
    }
    
    var body: some View {
        if let url = group.imgUrl {
            LazyImage(url: url) { state in
                switch state.result {
                case .none:
                    ColorSet.color(groupColor)
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.75)
                        .allowsHitTesting(false)
                        .zIndex(0)
                case .failure(_):
                    ColorSet.color(groupColor)
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
            ColorSet.color(groupColor)
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.75)
                .allowsHitTesting(false)
                .zIndex(0)
        }
    }
}
