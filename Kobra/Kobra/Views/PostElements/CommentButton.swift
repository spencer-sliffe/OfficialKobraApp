//
//  CommentButton.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/17/24.
//

import Foundation
import SwiftUI

struct CommentButton: View {
    let post: Post
    @Binding var showingComments: Bool
    
    var body: some View {
        Button(action: {
            // Implement comment action
            showingComments.toggle()
        }) {
            HStack {
                Image(systemName: "bubble.right")
                    .foregroundColor(.gray)
                Text("\(post.numComments)")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(5)
                    .background(Color.blue.opacity(0.5))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.blue, lineWidth: 1)
                    )
            }
        }
    }
}
