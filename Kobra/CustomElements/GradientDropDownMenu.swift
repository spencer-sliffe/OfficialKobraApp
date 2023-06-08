//
//  GradientDropDownMenu.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/18/23.
//

import Foundation
import SwiftUI

struct GradientDropDownMenu: View {
    @Binding var isExpanded: Bool
    let options: [(String, LinearGradient)]
    @Binding var selection: String
    let onOptionSelected: (Int) -> Void
    
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
            .background(Color.clear)
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(options.indices, id: \.self) { index in
                            VStack {
                                Text(options[index].0) // This is the label of the gradient
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(selection == options[index].0 ? .blue : .white)
                                options[index].1 // This is the LinearGradient
                                    .frame(height: 20)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.clear)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selection = options[index].0
                                    isExpanded = false
                                    onOptionSelected(index)
                                }
                            }
                            if index != options.count - 1 {
                                Divider().background(Color.white)
                            }
                        }
                    }
                    .background(Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .shadow(radius: 5)
                    .transition(.move(edge: .top))
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
            }
        }
    }
}
