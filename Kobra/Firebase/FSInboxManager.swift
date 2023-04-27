//
//  FireStoreManager.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/18/23.
//

import SwiftUI
import Combine
import Firebase

class FSInboxManager {
    static let shared = FSInboxManager()
    private let db = Firestore.firestore()
    
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
}
