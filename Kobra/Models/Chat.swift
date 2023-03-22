//
//  Chat.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/14/23.
//

struct Chat: Identifiable {
    let id: String
    let participants: [String]
    let lastMessage: ChatMessage?

    init(id: String, participants: [String], lastMessage: ChatMessage? = nil) {
        self.id = id
        self.participants = participants
        self.lastMessage = lastMessage
    }

    func otherParticipantEmail(for currentUserEmail: String) -> String {
        return participants.filter({ $0 != currentUserEmail }).first ?? ""
    }
}

