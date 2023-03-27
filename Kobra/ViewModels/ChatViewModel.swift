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
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    private let firestoreManager = FirestoreManager.shared
    var chatListener: ListenerRegistration?
    
    init(chat: Chat) {
        self.chat = chat
    }

    func fetchMessages() {
        isLoading = true
        chatListener?.remove() // Remove any existing listener
        chatListener = firestoreManager.observeMessages(forChat: chat) { [weak self] result in
            guard let self = self else { return } // make sure self is still available
            self.isLoading = false
            switch result {
            case .success(let messages):
                self.messages = messages
                self.delegate?.didUpdateChat(self.chat)
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
}

struct MessageRow: View {
    var message: ChatMessage
    var isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                Text(message.text)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.blue)
                    .cornerRadius(10)
            } else {
                Text(message.text)
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.gray)
                    .cornerRadius(10)
                Spacer()
            }
        }
    }
}
