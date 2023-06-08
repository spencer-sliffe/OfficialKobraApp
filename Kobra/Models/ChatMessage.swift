//
//  ChatMessage.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/18/23.
//

import Foundation

struct ChatMessage: Identifiable, Equatable, Hashable {
    let id: String
    let sender: String
    let text: String
    let timestamp: Date
    let isRead: Bool

    init(sender: String, text: String, timestamp: Date = Date(), isRead: Bool) {
        self.id = UUID().uuidString
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.isRead = isRead
    }

    init(id: String, sender: String, text: String, timestamp: Date, isRead: Bool) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.isRead = isRead
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

