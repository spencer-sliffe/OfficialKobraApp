//
//  AccountSearchBar.swift
//  Kobra
//
//  Created by Spencer SLiffe on 6/7/23.
//

import Foundation
import SwiftUI

struct AccountSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search...", text: $text)
                .foregroundColor(.primary)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 10)
    }
}

