//
//  CustomTextField.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/3/23.
//

import Foundation
import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var onEditingChanged: (Bool) -> Void = { _ in }
    @State private var dynamicHeight: CGFloat = 40
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextEditor(text: $text)
                .onChange(of: text) { value in
                    self.onEditingChanged(true)
                    let height = value.height(withConstrainedWidth: UIScreen.main.bounds.width - 40, font: .systemFont(ofSize: 16))
                    self.dynamicHeight = max(20, height + 20)
                }
                .frame(height: dynamicHeight)
                .padding(.horizontal, 8)
                .scrollContentBackground(.hidden) // <- Hide it
                .foregroundColor(Color.white)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 8)
            }
        }
    }
}


// String extension to calculate height of text
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}



