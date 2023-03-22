//
//  ChatViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/11/23.
//
import Firebase
import FirebaseFirestore
import SwiftUI
import Combine

protocol ChatDelegate: AnyObject {
    func didUpdateChat(_ chat: Chat)
}

class ChatViewModel: ObservableObject {
    weak var delegate: ChatDelegate?
    var chat: Chat
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    var chatListener: ListenerRegistration?
    
    init(chat: Chat) {
        self.chat = chat
    }

    func fetchMessages() {
        isLoading = true
        chatListener?.remove() // Remove any existing listener
        chatListener = db.collection("chats")
            .document(chat.id)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return } // make sure self is still available
                self.isLoading = false
                print("chats loaded")
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let snapshot = snapshot {
                    self.messages = snapshot.documents.compactMap {
                        guard let sender = $0.data()["sender"] as? String,
                              let text = $0.data()["text"] as? String,
                              let timestamp = ($0.data()["timestamp"] as? Timestamp)?.dateValue()
                        else { return nil }
                        return ChatMessage(id: $0.documentID, sender: sender, text: text, timestamp: timestamp)
                    }
                    self.delegate?.didUpdateChat(self.chat)
                }
            }
    }

    func sendMessage(_ message: String) {
        let messageData = [
            "sender": Auth.auth().currentUser?.email ?? "",
            "text": message,
            "timestamp": FieldValue.serverTimestamp()
        ] as [String: Any]
        db.collection("chats")
            .document(chat.id)
            .collection("messages")
            .addDocument(data: messageData) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.delegate?.didUpdateChat(self.chat)
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
