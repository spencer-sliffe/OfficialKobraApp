//
//  ChatView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23.
import SwiftUI
import Combine
import Firebase
import FirebaseFirestore
import Foundation

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    let chat: Chat
    let currentUserEmail: String
    var listener: ListenerRegistration?

    init(chat: Chat, currentUserEmail: String) {
        self.chat = chat
        self.currentUserEmail = currentUserEmail
        self.listener = FSChatManager.shared.observeMessages(forChat: chat) { result in
            switch result {
            case .success(let messages):
                self.messages = messages
            case .failure(let error):
                print("Error observing messages: \(error)")
            }
        }
    }

    var body: some View {
        VStack {
            List {
                ForEach(messages) { message in
                    Text("\(message.sender): \(message.text)")
                }
            }

            HStack {
                TextField("New message", text: $newMessage)
                Button(action: {
                    FSChatManager.shared.sendMessage(chatId: chat.id, message: newMessage, sender: currentUserEmail) { error in
                        if let error = error {
                            print("Error sending message: \(error)")
                        } else {
                            newMessage = ""
                            FSChatManager.shared.markMessagesAsRead(forChat: chat, currentUserEmail: currentUserEmail)
                        }
                    }
                }) {
                    Text("Send")
                }
            }
        }
        .onAppear {
            FSChatManager.shared.fetchMessages(chatId: chat.id) { result in
                switch result {
                case .success(let messages):
                    self.messages = messages
                case .failure(let error):
                    print("Error fetching messages: \(error)")
                }
            }
        }
        .onDisappear {
            listener?.remove()
        }
    }
}

