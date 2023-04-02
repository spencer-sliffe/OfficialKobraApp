//
//  FireStoreManager.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/18/23.
//

import SwiftUI
import Combine
import Firebase

class FirestoreManager {
    static let shared = FirestoreManager()
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
    
    
    func observeChats(forUserWithEmail userEmail: String, completion: @escaping (Result<[Chat], Error>) -> Void) -> ListenerRegistration? {
        print("observeChats is running in manager")
        return db.collection("chats")
            .whereField("participants", arrayContains: userEmail)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let chats = snapshot.documents.compactMap { document -> Chat? in
                        guard let participants = document.data()["participants"] as? [String] else {
                            return nil
                        }
                        guard let lastMessageData = document.data()["lastMessage"] as? [String: Any],
                              let sender = lastMessageData["sender"] as? String,
                              let text = lastMessageData["text"] as? String,
                              let timestamp = (lastMessageData["timestamp"] as? Timestamp)?.dateValue(),
                              let isRead = lastMessageData["isRead"] as? Bool
                        else {
                            return nil
                        }
                        let lastMessage = ChatMessage(sender: sender, text: text, timestamp: timestamp, isRead: isRead)
                        return Chat(id: document.documentID, participants: participants, lastMessage: lastMessage)
                    }
                    
                    completion(.success(chats))
                }
            }
    }
    
    
    func createChat(withUserWithEmail userEmail: String, currentUserEmail: String, completion: @escaping (Result<Chat, Error>) -> Void) {
        print("createChat is running in manager")
        let chatRef = db.collection("chats").document()
        let messageData1 = [
            "sender": currentUserEmail,
            "text": "",
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
        ] as [String: Any]
        chatRef.setData([
            "participants": [userEmail, currentUserEmail], "lastMessage": messageData1
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let chat = Chat(id: chatRef.documentID, participants: [userEmail, currentUserEmail])
                completion(.success(chat))
            }
        }
    }
    
    func observeUnreadMessageCount(forChat chat: Chat, currentUserEmail: String, completion: @escaping (Result<Int, Error>) -> Void) ->
    ListenerRegistration {
        print("observeUnreadMessageCount is running in manager")
        return db.collection("chats")
            .document(chat.id)
            .collection("messages")
            .whereField("sender", isNotEqualTo: currentUserEmail)
            .whereField("isRead", isEqualTo: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let snapshot = snapshot {
                    completion(.success(snapshot.documents.count))
                    print("Observe Unread Message Count ran successfully in FireStoreManager")
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
