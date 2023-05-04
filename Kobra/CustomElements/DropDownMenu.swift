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
                            Text(options[index])
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .background(Color.clear)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selection = options[index]
                                        isExpanded = false
                                        onOptionSelected(index)
                                    }
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
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
            }
        }
    }
}
