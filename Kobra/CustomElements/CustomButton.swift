//
//  CustomButton.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/3/23.
//

import Foundation
import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(radius: 5)
        }
    }
}
