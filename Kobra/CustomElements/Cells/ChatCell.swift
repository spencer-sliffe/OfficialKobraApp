//
//  ChatCell.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/8/23.
//

import Foundation
import SwiftUI

struct ChatCell: View {
    var chat: Chat
    
    var body: some View {
        HStack(spacing: 15) {
            // Profile Picture
            Image(systemName: "person.crop.circle.fill") // Replace with actual user's avatar
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .foregroundColor(.gray) // Placeholder color
            
            VStack(alignment: .leading, spacing: 4) {
                // Username
                Text(chat.username)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Last Message
                if let lastMessage = chat.lastMessage {
                    if(lastMessage != "") {
                        Text(lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    } else {
                        Text("NO MESSAGES YET")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            
            Spacer()
            
            // Timestamp
            Text(chat.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground)) // Use a subtle background color
        .clipShape(RoundedRectangle(cornerRadius: 10)) // Rounded corners
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1) // Adding a border
        )
    }
}
