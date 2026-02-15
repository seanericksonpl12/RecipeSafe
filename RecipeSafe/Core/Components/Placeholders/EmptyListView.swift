//
//  EmptyListView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/29/23.
//

import SwiftUI

struct EmptyListView: View {
  
//  @State var yOffset: CGFloat = 0.0
  var description: String
  
  var body: some View {
    VStack {
      Text("empty.title".localized)
        .font(.title)
        .fontWeight(.heavy)
        .foregroundColor(.gray)
        .padding()
      ZStack(alignment: .top) {
        Text(description)
          .font(.callout)
          .foregroundColor(.gray)
          .padding(.horizontal)
          .multilineTextAlignment(.center)
        Image("logo-clear")
          .resizable()
          .scaledToFill()
          .frame(maxWidth: 150, maxHeight: 150)
          .opacity(0.5)
          .padding(.top, 50)
      }
    }
//    .offset(y: yOffset)
//    .gesture(
//      DragGesture()
//        .onChanged { value in
//          yOffset = (value.translation.height / 2)
//        }
//        .onEnded { _ in
//          withAnimation {
//            yOffset = 0
//          }
//        }
//    )
  }
}

struct EmptyListModifier: ViewModifier {
  
  let isHidden: Bool
  let description: String
  
  func body(content: Content) -> some View {
    content
      .overlay(isHidden ? EmptyListView(description: description) : nil)
  }
}

extension View {
  func emptyModifier(isHidden: Bool, description: String) -> some View {
    self.modifier(EmptyListModifier(isHidden: isHidden, description: description))
  }
}
