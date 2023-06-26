//
//  MessageRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 6/22/23.
//

import Foundation
import SwiftUI

struct MessageRow: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                messageContent
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                messageContent
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
        }
    }
    
    private var messageContent: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading) {
            Text(message.text)
                .foregroundColor(.white)
                .padding(1)
                .background(Color.clear)
            Text(message.timestamp, style: .time)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

