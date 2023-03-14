//
//  Chat.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/14/23.
//

import Foundation

struct Chat {
    let id: String
    let participants: [String]
    var messages: [Message] = []
}


struct Message {
    let sender: String
    let text: String
    let timestamp: Date
}

protocol ChatDelegate: AnyObject {
    func startChat(with chat: Chat)
    func chat(_ chat: Chat, didReceiveNewMessage message: Message)
}
