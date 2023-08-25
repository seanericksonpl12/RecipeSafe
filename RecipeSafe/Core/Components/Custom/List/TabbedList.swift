//
//  TabbedList.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/18/23.
//

import SwiftUI

struct TabbedList<Content: View>: View {
    
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    var textFieldTitle: Binding<String>
    var editing: Binding<Bool>
    var textFieldPrompt: String?
    var content: Content
    
    // MARK: - Private
    @State private var charLimit: Int = 100
    
    // MARK: - Init
    init(textFieldTitle: Binding<String>, editing: Binding<Bool>, textFieldPrompt: String?, @ViewBuilder _ content: () -> Content) {
        self.textFieldTitle = textFieldTitle
        self.editing = editing
        self.textFieldPrompt = textFieldPrompt
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                // MARK: - List Overlay
                if textFieldTitle.wrappedValue != " " || editing.wrappedValue {
                    VStack {
                        HStack {
                            TextField("", text: textFieldTitle, prompt: Text(textFieldPrompt ?? ""), axis: .horizontal)
                                .font(.title)
                                .fontWeight(.heavy)
                                .disabled(!editing.wrappedValue)
                                .padding()
                                .padding(.trailing)
                                .zIndex(2)
                                .padding(.top, -50)
                            Spacer()
                        }
                        .padding(.leading)
                        Spacer()
                    }
                    .zIndex(2)
                }
                
                // MARK: - List
                List {
                    content
                }
                .zIndex(1)
                
                // MARK: - List Background
                if textFieldTitle.wrappedValue != " " || editing.wrappedValue {
                    VStack {
                        HStack {
                            Text(textFieldTitle.wrappedValue == "" ? textFieldPrompt ??
                                 String(textFieldTitle.wrappedValue.prefix(charLimit)) :
                                    String(textFieldTitle.wrappedValue.prefix(charLimit)))
                                .font(.title)
                                .fontWeight(.heavy)
                                .disabled(true)
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 25))
                                .hidden()
                                .onChange(of: textFieldTitle.wrappedValue) { text in
                                    self.textFieldTitle.wrappedValue = text
                                    if text.isEmpty {
                                        textFieldTitle.wrappedValue = " "
                                    }
                                    if text.count > 1 && text[text.startIndex] == " " {
                                        textFieldTitle.wrappedValue.removeFirst()
                                    }
                                }
                                .background {
                                    InverseRoundedRectangle(radius: 15)
                                        .fill(colorScheme == .light ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .systemBackground))
                                        .zIndex(0)
                                    GeometryReader { proxy in
                                        Color.clear
                                            .onChange(of: textFieldTitle.wrappedValue) { text in
                                                if proxy.size.width >= geo.size.width * 0.9 {
                                                    charLimit = textFieldTitle.wrappedValue.count - 1
                                                }
                                            }
                                    }
                                }
                                .padding(.top, -43.5)
                            Spacer()
                        }
                        .padding(.leading)
                        Spacer()
                    }
                }
            }
        }
    }
}
