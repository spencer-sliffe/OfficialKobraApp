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
    var lastMessage: String?
    var timestamp: Date
    var username: String
    var profilePicture: URL?

    init(id: UUID = UUID(), participants: [String], lastMessage: String = "", timestamp: Date, username: String, profilePicture: String?) {
        self.id = id
        self.participants = participants
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.username = username
        self.profilePicture = profilePicture.flatMap { URL(string: $0) }
    }
}

