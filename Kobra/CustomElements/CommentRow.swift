//
//  CommentRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/13/23.
//

import SwiftUI

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(comment.commenter)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("•")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(comment.text)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

