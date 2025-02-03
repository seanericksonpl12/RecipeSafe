//
//  SearchSuggestionItem.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/18/24.
//

import SwiftUI

struct SearchList<Content: View, Style: PrimitiveButtonStyle>: View {

    @Binding var text: String
    
    var data: [String]
    var content: (String) -> Content
    var buttonStyle: Style
    var searchAction: (String) -> Void
    
    init(
        _ data: [String],
        text: Binding<String>,
        buttonStyle: Style = PlainButtonStyle(),
        @ViewBuilder content: @escaping (String) -> Content,
        action: @escaping (String) -> Void
    ) {
        self.data = data
        self._text = text
        self.buttonStyle = buttonStyle
        self.content = content
        self.searchAction = action
    }
    
    var body: some View {
        ForEach(Array(data.toIdentifiable().enumerated()), id: \.element.id) { index, item in
            Button {
                searchAction(item.value)
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.trailing, 5)
                    VStack {
                        
                        HStack {
                            content(item.value)
                            Spacer()
                        }
                        if index != data.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding([.leading, .trailing])
            }.buttonStyle(self.buttonStyle)
        }
        
        if !text.isEmpty {
            Button {
                searchAction(text)
            } label: {
                VStack {
                    HStack {
                        Text("Nothing Found")
                            .font(.callout)
                            .fontWeight(.bold)
                            .padding(.leading)
                        Spacer()
                    }
                    Divider()
                        .padding([.leading, .trailing])
                    HStack {
                        Image(systemName: "rectangle.and.text.magnifyingglass")
                            .padding(.leading)
                        Text("Find \"\(text)\"")
                        Spacer()
                    }
                }
                .padding(.top)
            }.buttonStyle(buttonStyle)
        }
    }
}
