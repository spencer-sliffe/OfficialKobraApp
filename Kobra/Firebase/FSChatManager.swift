//
//  FSChatManager.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/27/23.
//

import SwiftUI
import Combine
import Firebase

class FSChatManager {
    static let shared = FSChatManager()
    private let db = Firestore.firestore()
    
    func fetchMessages(chatId: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) {
        print("fetchMessages is running in manager")
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let messages = snapshot?.documents.compactMap { document -> ChatMessage? in
                    guard let sender = document.data()["sender"] as? String,
                          let text = document.data()["text"] as? String,
                          let timestamp = (document.data()["timestamp"] as? Timestamp)?.dateValue(),
                          let isRead = document.data()["isRead"] as? Bool
                    else { return nil }
                    
                    return ChatMessage(id: document.documentID, sender: sender, text: text, timestamp: timestamp, isRead: isRead)
                } ?? []
                completion(.success(messages))
            }
    }
    
    func observeMessages(forChat chat: Chat, completion: @escaping (Result<[ChatMessage], Error>) -> Void) -> ListenerRegistration {
        print("observeMessages is running in manager")
        return db.collection("chats")
            .document(chat.id)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let messages = snapshot?.documents.compactMap { document -> ChatMessage? in
                    guard let sender = document.data()["sender"] as? String,
                          let text = document.data()["text"] as? String,
                          let timestamp = (document.data()["timestamp"] as? Timestamp)?.dateValue(),
                          let isRead = document.data()["isRead"] as? Bool
                    else { return nil }
                    return ChatMessage(id: document.documentID, sender: sender, text: text, timestamp: timestamp, isRead: isRead)
                } ?? []
                completion(.success(messages))
            }
    }
    
    func sendMessage(chatId: String, message: String, sender: String, completion: @escaping (Error?) -> Void) {
        print("sendMessage is running in manager")
        let messageData = [
            "sender": sender,
            "text": message,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
        ] as [String: Any]
        self.db.collection("chats")
            .document(chatId)
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    completion(error)
                    return
                }
                // Update last message in chat
                let chatRef = self.db.collection("chats").document(chatId)
                chatRef.updateData([
                    "lastMessage": messageData
                ]) { error in
                    completion(error)
                }
            }
    }
    
    func markMessagesAsRead(forChat chat: Chat, currentUserEmail: String) {
        print("markMessagesAsRead is running in manager")
        db.collection("chats")
            .document(chat.id)
            .collection("messages")
            .whereField("sender", isNotEqualTo: currentUserEmail)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error marking messages as read: \(error.localizedDescription)")
                    return
                }
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents {
                    self.db.collection("chats")
                        .document(chat.id)
                        .collection("messages")
                        .document(document.documentID)
                        .updateData(["isRead": true]) { error in
                            if let error = error {
                                print("Error updating message as read: \(error.localizedDescription)")
                            }
                            print("Messages updated as read successfully")
                        }
                }
            }
    }
}
