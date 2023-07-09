//
//  Chat.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/14/23.
//
import Foundation

struct Chat: Identifiable {
    var id = UUID()
    var participants: [String]
    var lastMessage: Message?
    var timestamp: Date
    var recentUsername: String

    init(id: UUID = UUID(), participants: [String], lastMessage: Message? = nil, timestamp: Date, recentUsername: String) {
        self.id = id
        self.participants = participants
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.recentUsername = recentUsername
    }
}

