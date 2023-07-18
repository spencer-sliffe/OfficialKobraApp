//
//  FSChatManager.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/27/23.
//

import SwiftUI
import Combine
import Firebase

class FSChatManager {
    private let db = Firestore.firestore()
    static let shared = FSChatManager()
    
    func fetchMessages(accountId: String, chatId: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        let query = db.collection("Accounts").document(accountId).collection("Inbox").document(chatId).collection("messages")
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var messages: [Message] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let message = self.createMessageFrom(data: data)
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    /*
     struct Message: Identifiable {
     var id = UUID()
     var senderId: String
     var receiverId: String
     var text: String
     var timestamp: Date
     var isRead: Bool
     
     */
    private func createMessageFrom(data: [String: Any]) -> Message {
        let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        let senderId = data["senderId"] as? String ?? ""
        let receiverId = data["receiverId"] as? String ?? ""
        let text = data["text"] as? String ?? ""
        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        let isRead = data["isRead"] as? Bool ?? false
        return Message(id: id, senderId: senderId, receiverId: receiverId, text: text, timestamp: timestamp, isRead: isRead)
    }
    
    func addMessage(_ message: Message, accountId: String, chatId: String, completion: @escaping (Result<Void, Error>) -> Void){
        let data = self.convertMessageToData(message)
        let query = db.collection("Accounts").document(accountId).collection("Inbox").document(chatId).collection("messages")
        query.addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func convertMessageToData(_ message: Message) -> [String: Any] {
        let data: [String: Any] = [
            "id": message.id.uuidString,
            "senderId": message.senderId,
            "receiverId": message.receiverId,
            "text": message.text,
            "timestamp": message.timestamp,
            "isRead": message.isRead
        ]
        return data
    }
}
