//
//  ChatViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/11/23.
//
import SwiftUI
import Combine
import Firebase

protocol ChatDelegate: AnyObject {
    func didUpdateChat(_ chat: Chat)
}

class ChatViewModel: ObservableObject {
    weak var delegate: ChatDelegate?
    var chat: Chat
    @Published var messages: [ChatMessage] = []
    @Published var isLoading2 = false
    private var cancellables = Set<AnyCancellable>()
    private let firestoreManager = FirestoreManager.shared
    var chatListener: ListenerRegistration?
    
    init(chat: Chat) {
        self.chat = chat
    }
    
    var currentUserEmail: String {
        return Auth.auth().currentUser?.email ?? ""
    }
    
    func fetchMessages() {
        isLoading2 = true
        // chatListener?.remove() // Remove any existing listener
        chatListener = firestoreManager.observeMessages(forChat: chat) { [weak self] result in
            guard let self = self else { return } // make sure self is still available
            self.isLoading2 = false
            
            switch result {
            case .success(let messages):
                self.messages = messages
                self.delegate?.didUpdateChat(self.chat)
                guard let currentUserEmail = Auth.auth().currentUser?.email else {
                    return
                }
                self.firestoreManager.markMessagesAsRead(forChat: self.chat, currentUserEmail: currentUserEmail)
            case .failure(let error):
                print(error.localizedDescription)
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

struct MessageRow: View {
    var message: ChatMessage
    var isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                VStack(alignment: .trailing) { // Align content to the trailing edge
                    Text(message.text)
                        .foregroundColor(.white)
                        .padding(1)
                        .background(Color.clear)
                        .multilineTextAlignment(.trailing)
                    Text(message.timestamp, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading) { // Align content to the leading edge
                    Text(message.text)
                        .foregroundColor(.white)
                        .padding(1)
                        .background(Color.clear)
                        .multilineTextAlignment(.leading)
                    Text(message.timestamp, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
        }
    }
}
