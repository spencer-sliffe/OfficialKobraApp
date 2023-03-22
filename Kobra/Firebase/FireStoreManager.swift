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
                              let timestamp = (document.data()["timestamp"] as? Timestamp)?.dateValue()
                        else { return nil }
                        
                        return ChatMessage(id: document.documentID, sender: sender, text: text, timestamp: timestamp)
                    } ?? []
                    
                    completion(.success(messages))
                }
        }

    func sendMessage(chatId: String, message: String, sender: String, completion: @escaping (Error?) -> Void) {
           let messageData = [
               "sender": sender,
               "text": message,
               "timestamp": FieldValue.serverTimestamp()
           ] as [String: Any]
           
           db.collection("chats")
               .document(chatId)
               .collection("messages")
               .addDocument(data: messageData) { error in
                   completion(error)
               }
       }
    
    func observeChats(forUserWithEmail userEmail: String) -> AnyPublisher<[Chat], Error> {
        let subject = PassthroughSubject<[Chat], Error>()
        
        db.collection("chats")
            .whereField("participants", arrayContains: userEmail)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                } else if let snapshot = snapshot {
                    let chats = snapshot.documents.compactMap { document -> Chat? in
                        guard let participants = document.data()["participants"] as? [String] else {
                            return nil
                        }
                        return Chat(id: document.documentID, participants: participants)
                    }
                    subject.send(chats)
                }
            }
        return subject.eraseToAnyPublisher()
    }

        func createChat(withUserWithEmail userEmail: String, currentUserEmail: String, completion: @escaping (Result<Chat, Error>) -> Void) {
            let chatRef = db.collection("chats").document()
            chatRef.setData([
                "participants": [userEmail, currentUserEmail],
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let chat = Chat(id: chatRef.documentID, participants: [userEmail, currentUserEmail])
                    completion(.success(chat))
                }
            }
        }
    
    func observeUnreadMessageCount(forChat chat: Chat, currentUserEmail: String, completion: @escaping (Result<Int, Error>) -> Void) -> ListenerRegistration {
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
                   }
               }
       }

       func markMessagesAsRead(forChat chat: Chat, currentUserEmail: String) {
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
                           }
                   }
               }
       }
}
