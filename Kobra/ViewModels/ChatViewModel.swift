//
//  ChatViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23.
//

import Foundation
import Combine
import FirebaseAuth

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private let chatManager = FSChatManager.shared
    var accountId: String?
    var chatId: String

    init(chatId: String) {
        self.chatId = chatId
        fetchCurrentUserId()
    }

    private func fetchCurrentUserId() {
        if let userId = Auth.auth().currentUser?.uid {
            self.accountId = userId
            fetchMessages()
        } else {
            print("No current user ID found")
            // Handle the situation where the user is not logged in
        }
    }

    func fetchMessages() {
        guard let accountId = accountId else {
            print("Account ID is not set")
            return
        }

        chatManager.fetchMessages(accountId: accountId, chatId: chatId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let messages):
                    self?.messages = messages
                case .failure(let error):
                    print("Error fetching messages: \(error.localizedDescription)")
                }
            }
        }
    }

    func sendMessage(text: String) {
        guard let accountId = accountId else {
            print("Account ID is not set")
            return
        }

        let newMessage = Message(id: UUID(), senderId: accountId, receiverId: "", text: text, timestamp: Date(), isRead: false)
        chatManager.addMessage(newMessage, accountId: accountId, chatId: chatId) { result in
            switch result {
            case .success():
                self.messages.append(newMessage)
            case .failure(let error):
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}

