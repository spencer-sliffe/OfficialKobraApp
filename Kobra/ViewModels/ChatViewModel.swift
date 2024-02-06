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
    var chatName: [String]
    
    var formattedChatName: String {
        return chatName.joined(separator: ", ")
    }
    
    init(chatId: String, chatName: [String]) {
        self.chatId = chatId
        self.chatName = chatName
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
                    self?.messages = messages.sorted(by: { $0.timestamp < $1.timestamp })
                case .failure(let error):
                    print("Error fetching messages: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func markMessagesAsRead() {
        guard let accountId = accountId else {
            print("Account ID is not set")
            return
        }
        chatManager.markMessagesAsRead(accountId: accountId, chatId: chatId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("Messages marked as read")
                    self?.updateMessagesAsRead()
                case .failure(let error):
                    print("Error marking messages as read: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateMessagesAsRead() {
        for index in messages.indices {
            messages[index].isRead = true
        }
    }
    
    func sendMessage(text: String) {
        guard let accountId = accountId else {
            print("Account ID is not set")
            return
        }
        
        let newMessage = Message(id: UUID(), senderId: accountId, receiverId: "", text: text, timestamp: Date(), isRead: false)
        chatManager.addMessage(newMessage, accountId: accountId, chatId: chatId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.messages.append(newMessage)  // Appending new message
                case .failure(let error):
                    print("Error sending message: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resetData() {
        messages = []
        accountId = nil
        // Other reset operations if needed
    }
}

