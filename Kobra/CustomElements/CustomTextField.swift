//
//  CustomTextField.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/3/23.
//

import Foundation
import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var onEditingChanged: (Bool) -> Void = { _ in }

    var body: some View {
        CustomTextFieldUI(text: $text, placeholder: placeholder, onEditingChanged: onEditingChanged)
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 1)
            )
    }
}