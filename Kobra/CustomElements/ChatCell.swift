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
       // NavigationLink(destination: ChatDetailView(chat: chat)) {
            HStack {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)  // replace this with your custom user's avatar

                VStack(alignment: .leading) {
                    Text(chat.recentUsername)
                        .font(.headline)
                        .foregroundColor(.white)

                    if let lastMessage = chat.lastMessage {
                        Text(lastMessage.text)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }

                    Text(chat.timestamp, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
            }
            .padding(.vertical, 8)
        //}
    }
}

