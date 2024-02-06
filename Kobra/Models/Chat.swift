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
    var profilePicture: URL?
    
    var formattedParticipants: String {
        let maxParticipantLength = 10 // Adjust this value as needed
        var participantsString = participants.joined(separator: ", ")
        if participantsString.count > maxParticipantLength {
            participantsString = String(participantsString.prefix(maxParticipantLength)) + "..."
        }
        return participantsString
    }

    init(id: UUID = UUID(), participants: [String], lastMessage: String = "", timestamp: Date, profilePicture: String?) {
        self.id = id
        self.participants = participants
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.profilePicture = profilePicture.flatMap { URL(string: $0) }
    }
}

