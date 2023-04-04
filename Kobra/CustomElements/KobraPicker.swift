//
//  KobraPicker.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/3/23.
//

import Foundation
import SwiftUI

struct KobraPicker<Content: View>: View {
    let content: () -> Content
    let title: String
    @Binding var selection: String

    init(title: String, selection: Binding<String>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.title = title
        self._selection = selection
    }

    var body: some View {
        VStack {
            Picker(selection: $selection, label: Text("")) {
                content()
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 1)
            )
        }
    }
}
