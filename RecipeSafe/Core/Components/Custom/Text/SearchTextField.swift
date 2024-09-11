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
    @objc optional func cancel()
}

struct SearchTextField: View {
    
    @Binding var text: String
    @Binding var isLoading: Bool
    
    @FocusState private var isFocused: Bool
    
    @State private var showCancel: Bool = false
    @State private var showRefresh: Bool = false
    
    let placeholder: String
    
    weak var delegate: SearchTextFieldDelegate?
    
    private var _onSubmit: (() -> Void)?
    private var _onCancel: (() -> Void)?
    private var _onRefresh: (() -> Void)?
    
    init(text: Binding<String>, isLoading: Binding<Bool>, placeholder: String, delegate: SearchTextFieldDelegate? = nil) {
        self._text = text
        self._isLoading = isLoading
        self.placeholder = placeholder
        self.delegate = delegate
    }
    
    private init(text: Binding<String>, 
                 isLoading: Binding<Bool>,
                 placeholder: String,
                 delegate: SearchTextFieldDelegate? = nil,
                 _onSubmit: (() -> Void)?,
                 _onCancel: (() -> Void)?,
                 _onRefresh: (() -> Void)?) {
        self._text = text
        self._isLoading = isLoading
        self.placeholder = placeholder
        self.delegate = delegate
        self._onSubmit = _onSubmit
        self._onCancel = _onCancel
        self._onRefresh = _onRefresh
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
                        _onSubmit?()
                    }
                    .onChange(of: isFocused) { focused in
                        withAnimation(.smooth) {
                            showCancel = focused
                        }
                    }
                    .onChange(of: isLoading) { loading in
                        withAnimation(.smooth) {
                            showRefresh = !loading
                        }
                    }
                Spacer()
                Button {
                    isLoading ? delegate?.cancel?() : delegate?.refresh?()
                    isLoading ? _onCancel?() : _onRefresh?()
                } label: {
                    Image(systemName: showRefresh ? "arrow.counterclockwise" : "x.circle.fill")
                        .padding(8)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("gray1"))
            }
            if showCancel {
                Button {
                    isFocused = false
                } label: {
                    Text("Cancel")
                }
                .transition(.move(edge: .trailing).combined(with: .offset(x: 50, y: 0)))
            }
        }
    }
}

extension SearchTextField {
    func searchActions(onSubmit: (() -> Void)?,
                       onCancel: (() -> Void)?,
                       onRefresh: (() -> Void)?) -> SearchTextField {
        SearchTextField(text: self.$text,
                        isLoading: _isLoading,
                        placeholder: placeholder,
                        delegate: delegate,
                        _onSubmit: onSubmit,
                        _onCancel: onCancel,
                        _onRefresh: onRefresh)
    }
}
