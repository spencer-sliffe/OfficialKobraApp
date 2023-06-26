//
//  ChatViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23.
//
import SwiftUI
import Combine
import Firebase

protocol ChatDelegate: AnyObject {
    func didUpdateChat(_ chat: Chat)
}

class ChatViewModel: ObservableObject {
    @Published var chat: Chat
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private let firestoreManager: FSChatManager
    private var chatListener: ListenerRegistration?
    
    weak var delegate: ChatDelegate?
    
    var currentUserEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }
    
    init(chat: Chat, firestoreManager: FSChatManager = FSChatManager.shared) {
        self.chat = chat
        self.firestoreManager = firestoreManager
        fetchMessages()
    }
    
    deinit {
        chatListener?.remove()
    }
    
    func fetchMessages() {
        isLoading = true
        chatListener = firestoreManager.observeMessages(forChat: chat) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let messages):
                    self.messages = messages
                    self.markMessagesAsRead()
                    self.delegate?.didUpdateChat(self.chat)
                }
            }
        }
    }
    
    func sendMessage(_ message: String) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            return
        }
        firestoreManager.sendMessage(chatId: chat.id, message: message, sender: currentUserEmail) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.delegate?.didUpdateChat(self.chat)
            }
        }
    }
    func markMessagesAsRead() {
        firestoreManager.markMessagesAsRead(forChat: chat, currentUserEmail: currentUserEmail)
    }
}
