//
//  ChatMessage.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/18/23.
//

import Foundation

struct ChatMessage: Identifiable, Equatable, Hashable {
    let id: String
    let sender: String
    let text: String
    let timestamp: Date

    init(sender: String, text: String, timestamp: Date = Date()) {
        self.id = UUID().uuidString
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }

    init(id: String, sender: String, text: String, timestamp: Date) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

