//
//  ChatMessage.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/18/23.
//

import Foundation

struct Message: Identifiable {
    var id = UUID()
    var senderId: String
    var receiverId: String
    var text: String
    var timestamp: Date
    var isRead: Bool

    init(id: UUID = UUID(), senderId: String, receiverId: String, text: String, timestamp: Date, isRead: Bool) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.text = text
        self.timestamp = timestamp
        self.isRead = isRead
    }
}

