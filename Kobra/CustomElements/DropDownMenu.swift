//
//  DropDownMenu.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/25/23.
//

import Foundation
import SwiftUI

struct DropDownMenu: View {
    @Binding var isExpanded: Bool
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        VStack {
            HStack {
                Text(selection)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: 13, height: 6)
                    .foregroundColor(.white)
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 1)
            )
            .shadow(radius: 5)
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.blue.opacity(0.8))
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selection = option
                                    isExpanded = false
                                }
                            }
                    }
                }
                .background(Color.blue.opacity(0.8))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(radius: 5)
            }
        }
    }
}
