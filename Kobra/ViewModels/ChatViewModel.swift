//
//  ChatViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/11/23.
//

import Foundation
import FirebaseFirestore
import Firebase

class ChatViewModel: ObservableObject {
    weak var delegate: ChatDelegate?
    @Published var isLoading = false
    @Published var messages: [String]?
    @Published var searchResults: [Account]?
    private let db = Firestore.firestore()
    private var chatListener: ListenerRegistration?
    
    func fetchMessages() {
        isLoading = true
        chatListener = db.collection("chats").document("exampleChat").collection("messages")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return } // make sure self is still available
                self.isLoading = false
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let snapshot = snapshot {
                    self.messages = snapshot.documents.compactMap {
                        $0.data()["text"] as? String
                    }
                }
            }
    }
    
    func sendMessage(_ message: String) {
        let data: [String: Any] = [
            "text": message,
            "timestamp": Timestamp()
        ]
        db.collection("chats").document("exampleChat").collection("messages").addDocument(data: data)
    }
    
    func searchUsers(email: String) {
        db.collection("accounts")
            .whereField("email", isEqualTo: email)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return } // make sure self is still available
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let querySnapshot = querySnapshot {
                    self.searchResults = querySnapshot.documents.compactMap {
                        let data = $0.data()
                        let id = $0.documentID
                        let email = data["email"] as? String ?? ""
                        let subscription = data["subscription"] as? Bool ?? false
                        let packageData = data["package"] as? [String: Any]
                        let account = Account(id: id, email: email, subscription: subscription, packageData: packageData)
                        return account
                    }
                }
            }
    }

    
    func startChat(with account: Account) {
        let document = db.collection("chats").document()
        let chatId = document.documentID
        let chatData: [String: Any] = [
            "id": chatId,
            "participants": [
                account.id,
                Auth.auth().currentUser?.uid ?? ""
            ]
        ]
        document.setData(chatData) { [weak self] error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let chat = Chat(id: chatId, participants: [account.id, Auth.auth().currentUser?.uid ?? ""])
            self?.delegate?.startChat(with: chat)
        }
    }

    deinit {
        chatListener?.remove()
    }
}

