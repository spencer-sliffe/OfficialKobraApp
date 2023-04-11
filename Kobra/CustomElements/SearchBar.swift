//
//  SearchBar.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/3/23.
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
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 1)
            )
            
            .overlay(
                HStack {
                    if !isEditing && text.isEmpty {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                        Text("Search")
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
                                .foregroundColor(.white)
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
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}
