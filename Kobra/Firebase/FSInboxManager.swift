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
    private let db = Firestore.firestore()
    static let shared = FSInboxManager()
    
    func fetchInbox(accountId: String, completion: @escaping (Result<[Chat], Error>) -> Void) {
        let query = db.collection("Accounts").document(accountId).collection("Inbox")
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var chats: [Chat] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let chat = self.createChatFrom(data: data)
                chats.append(chat)
            }
            completion(.success(chats))
        }
    }
    
    private func createChatFrom(data: [String: Any]) -> Chat {
        let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        let participants = data["participants"] as? [String] ?? [""]
        let lastMessage = data["lastMessage"] as? Message ?? nil
        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        let recentUsername = data["recentUsername"] as? String ?? ""
        
        return Chat(id: id, participants: participants, lastMessage: lastMessage, timestamp: timestamp, recentUsername: recentUsername)
    }
    
    func addChat(_ chat: Chat, accountId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let data = self.convertChatToData(chat)
        let query = db.collection("Accounts").document(accountId).collection("Inbox")
        query.addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func convertChatToData(_ chat: Chat) -> [String: Any] {
        let data: [String: Any] = [
            "id": chat.id.uuidString,
            "participantA": chat.participants,
            "lastMessage": chat.lastMessage ?? "",  // this line might need further modification
            "timestamp": chat.timestamp,
            "recentUsername": chat.recentUsername
        ]
        return data
    }
}
