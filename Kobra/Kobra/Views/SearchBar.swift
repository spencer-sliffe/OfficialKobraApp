//
//  SearchBar.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/3/23.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("", text: $text, onEditingChanged: { isEditing in
                self.isEditing = isEditing
            })
            .background(Color.clear)
            .foregroundColor(.white)
            .textFieldStyle(PlainTextFieldStyle()) // Changed to PlainTextFieldStyle
            .padding(.horizontal, 8) // Add padding to the TextField
            .overlay(
                RoundedRectangle(cornerRadius: 10) // Add a RoundedRectangle for the border
                    .stroke(Color.white, lineWidth: 1)
            )
            .overlay(
                HStack {
                    if !isEditing && text.isEmpty {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    if !text.isEmpty {
                        Button(action: {
                            withAnimation {
                                text = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .opacity(text == "" ? 0 : 1)
                        }
                    }
                }
                .padding(.horizontal, 8),
                alignment: .leading // Set the alignment of the HStack overlay to .leading
            )
            if isEditing {
                Button("Cancel") {
                    UIApplication.shared.endEditing()
                    isEditing = false
                    text = ""
                }
                .foregroundColor(.white)
            }
        }
        .padding(8)
    }
}



extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}
