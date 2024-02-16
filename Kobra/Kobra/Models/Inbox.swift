//
//  Inbox.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/8/23.
//

import Foundation

struct Inbox: Identifiable {
    var id = UUID()
    var accountId: String
    var chats: [Chat]
    
    init(id: UUID = UUID(), accountId: String, chats: [Chat]) {
        self.id = id
        self.accountId = accountId
        self.chats = chats
    }
}
