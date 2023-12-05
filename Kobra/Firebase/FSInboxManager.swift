//  FSInboxManager.swift
//  Kobra
//  Created by Spencer Sliffe on 3/18/23.
//

import SwiftUI
import Combine
import Firebase

class FSInboxManager {
    private let db = Firestore.firestore()
    static let shared = FSInboxManager()
    private let accountCollection = "Accounts"

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
    
    /*private func fetchProfilePicture(accountId: String, completion: @escaping (Result<String, Error>)-> String) {
        let query = db.collection("Accounts").document(accountId)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var profilePicture = ""
            
        }
    }*/
    
    private func createChatFrom(data: [String: Any]) -> Chat {
        let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        let participants = data["participants"] as? [String] ?? [""]
        let lastMessage = data["lastMessage"] as? String ?? ""
        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        let username = data["username"] as? String ?? ""
        let profilePicture = data["profilePicture"] as? String ?? ""
        
        return Chat(id: id, participants: participants, lastMessage: lastMessage, timestamp: timestamp, username: username, profilePicture: profilePicture)
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
            "participants": chat.participants,
            "lastMessage": chat.lastMessage ?? "",  // this line might need further modification
            "timestamp": chat.timestamp,
            "username": chat.username,
            "profilePicture": chat.profilePicture ?? ""
        ]
        return data
    }
    
    func deleteChat(chatId: String, accountId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("Accounts").document(accountId).collection("Inbox").document(chatId).delete() { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func checkIfUserNameValid(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("Accounts").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let document = querySnapshot?.documents.first {
                let accountId = document.documentID
                completion(.success(accountId))
            } else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Username not found"])))
            }
        }
    }
}
