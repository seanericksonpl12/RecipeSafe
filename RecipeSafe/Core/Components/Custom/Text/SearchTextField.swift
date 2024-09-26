//
//  SearchTextField.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/10/24.
//

import SwiftUI

@MainActor @objc
protocol SearchTextFieldDelegate: AnyObject {
    @objc optional func submit()
    @objc optional func refresh()
    @objc optional func clear()
    @objc optional func cancel()
}

struct SearchTextField: View {
    
    private enum ButtonState: String {
        case refresh = "arrow.counterclockwise"
        case cancel = "x.circle.fill"
        case none = ""
    }
    
    @Binding var text: String
    var isFocusing: Binding<Bool>?
    
    @FocusState private var isFocused: Bool
    
    @State private var showCancel: Bool = false
    @State private var buttonState: ButtonState = .none
    @State private var hasMadeSearch: Bool = false
    
    let placeholder: String
    
    weak var delegate: SearchTextFieldDelegate?
    
    init(text: Binding<String>, isFocusing: Binding<Bool>?, placeholder: String, delegate: SearchTextFieldDelegate?) {
        self._text = text
        self.placeholder = placeholder
        self.delegate = delegate
        self.isFocusing = isFocusing
    }

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color("gray2"))
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: -4))
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color("gray2")))
                    .focused($isFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        delegate?.submit?()
                        hasMadeSearch = true
                    }
                    .onChange(of: isFocused) { old, new in
                        withAnimation(.interactiveSpring) {
                            isFocusing?.wrappedValue = new
                        }
                        withAnimation(.smooth) {
                            showCancel = new
                        }
                        refreshButtonState()
                    }
                    .onChange(of: isFocusing?.wrappedValue) { old, new in
                        if let focus = new {
                            isFocused = focus
                        }
                    }
                Spacer()
                if buttonState != .none {
                    Button {
                        switch buttonState {
                        case .refresh:
                            delegate?.refresh?()
                        case .cancel:
                            delegate?.clear?()
                        case .none:
                            return
                        }
                        refreshButtonState()
                    } label: {
                        Image(systemName: buttonState.rawValue)
                            .padding(8)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("gray1"))
            }
            if showCancel {
                Button {
                    delegate?.cancel?()
                } label: {
                    Text("Cancel")
                }
                .transition(.move(edge: .trailing).combined(with: .offset(x: 50, y: 0)))
            }
        }
    }
}

extension SearchTextField {
    
    func refreshButtonState() {
        if text.isEmpty && !isFocused {
            withAnimation {
                buttonState = .none
            }
        } else {
            withAnimation {
                buttonState = .cancel
            }
        }
    }
}
