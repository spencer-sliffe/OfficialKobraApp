//
//  CustomUITextField.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/3/23.
//

import Foundation
import UIKit
import SwiftUI

struct CustomTextFieldUI: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onEditingChanged: (Bool) -> Void = { _ in }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.text = text
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 16)
        textView.isScrollEnabled = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.maximumNumberOfLines = 0
        
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = .gray
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text == placeholder {
            uiView.text = nil
            uiView.textColor = .white
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextFieldUI
        
        init(_ parent: CustomTextFieldUI) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = nil
                textView.textColor = .white
            }
            parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = nil
                textView.textColor = .white
            }
            parent.onEditingChanged(true)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .gray
            }
            parent.onEditingChanged(false)
        }
    }
}

