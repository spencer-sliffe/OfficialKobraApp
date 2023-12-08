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
        // First, find the chat document where 'id' field equals chatId
        db.collection("Accounts").document(accountId).collection("Inbox").whereField("id", isEqualTo: chatId).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = querySnapshot?.documents.first else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Chat document not found"])))
                return
            }

            // Now fetch messages from the 'messages' subcollection of the found chat document
            let messagesQuery = document.reference.collection("messages")
            messagesQuery.getDocuments { (messagesSnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                var messages: [Message] = []
                messagesSnapshot?.documents.forEach { messageDocument in
                    let data = messageDocument.data()
                    let message = self.createMessageFrom(data: data)
                    messages.append(message)
                }
                completion(.success(messages))
            }
        }
    }

    func fetchParticipants(accountId: String, chatId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        // Query the Inbox collection to find the document with the specified chatId
        db.collection("Accounts").document(accountId).collection("Inbox").whereField("id", isEqualTo: chatId).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = querySnapshot?.documents.first else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Chat document not found"])))
                return
            }

            // Fetch the participants array from the chat document
            guard let usernames = document.data()["participants"] as? [String] else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Participants field not found"])))
                return
            }

            // Fetch account IDs for each username
            self?.fetchAccountIds(forUsernames: usernames, completion: completion)
        }
    }

    private func fetchAccountIds(forUsernames usernames: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        var accountIds: [String] = []
        let group = DispatchGroup()

        for username in usernames {
            group.enter()
            // Query to find account ID for each username
            db.collection("Accounts").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
                defer { group.leave() }

                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let accountId = querySnapshot?.documents.first?.documentID {
                    accountIds.append(accountId)
                }
            }
        }

        group.notify(queue: .main) {
            completion(.success(accountIds))
        }
    }

   
    private func createMessageFrom(data: [String: Any]) -> Message {
        let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        let senderId = data["senderId"] as? String ?? ""
        let receiverId = data["receiverId"] as? String ?? ""
        let text = data["text"] as? String ?? ""
        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        let isRead = data["isRead"] as? Bool ?? false
        return Message(id: id, senderId: senderId, receiverId: receiverId, text: text, timestamp: timestamp, isRead: isRead)
    }
    
    func addMessage(_ message: Message, accountId: String, chatId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Fetch participants for the given chatId
        fetchParticipants(accountId: accountId, chatId: chatId) { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(let participants):
                let group = DispatchGroup()
                var firstError: Error?

                // Function to add message to a participant's chat
                func addMessageToChat(participantAccountId: String) {
                    group.enter()
                    // First, find the chat document where 'id' field equals chatId for the participant
                    self?.db.collection("Accounts").document(participantAccountId).collection("Inbox").whereField("id", isEqualTo: chatId).getDocuments { (querySnapshot, error) in
                        if let error = error {
                            if firstError == nil {
                                firstError = error
                            }
                            group.leave()
                            return
                        }

                        guard let document = querySnapshot?.documents.first else {
                            if firstError == nil {
                                firstError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Chat document not found"])
                            }
                            group.leave()
                            return
                        }

                        // Reference to the 'messages' subcollection of the found chat document
                        let messagesRef = document.reference.collection("messages")

                        // Add the new message document to the 'messages' collection
                        messagesRef.addDocument(data: self?.convertMessageToData(message) ?? [:]) { error in
                            if let error = error, firstError == nil {
                                firstError = error
                            }

                            // Update the 'lastMessage' and 'timestamp' fields of the Chat document
                            document.reference.updateData([
                                "lastMessage": message.text,
                                "timestamp": Timestamp(date: message.timestamp)
                            ]) { error in
                                if let error = error, firstError == nil {
                                    firstError = error
                                }
                                group.leave()
                            }
                        }
                    }
                }

                // Add message to each participant's chat
                for participant in participants {
                    addMessageToChat(participantAccountId: participant)
                }

                // Also add the message to the sender's chat
                addMessageToChat(participantAccountId: accountId)

                // Final completion handling
                group.notify(queue: .main) {
                    if let error = firstError {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }


    private func addMessageToParticipant(_ message: Message, participantAccountId: String, chatId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Use participantAccountId to locate the specific chat and add the message
        let messagesRef = db.collection("Accounts").document(participantAccountId).collection("Inbox").document(chatId).collection("messages")
        
        // Add the new message document to the 'messages' collection
        messagesRef.addDocument(data: self.convertMessageToData(message)) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Update the 'lastMessage' and 'timestamp' fields of the Chat document
            let chatRef = self.db.collection("Accounts").document(participantAccountId).collection("Inbox").document(chatId)
            chatRef.updateData([
                "lastMessage": message.text,
                "timestamp": Timestamp(date: message.timestamp)
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
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
