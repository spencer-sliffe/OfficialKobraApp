//
//  CommentRow.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/13/23.
//

import SwiftUI

struct CommentRow: View {
    let comment: Comment

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(comment.commenter) // Display the user ID for now
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            Text(comment.text)
                .font(.body)
                .foregroundColor(.primary)
            HStack {
                Text(comment.timestamp, style: .date)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}


