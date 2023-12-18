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

    private func fetchInbox(accountId: String, completion: @escaping (Result<[Chat], Error>) -> Void) {
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
    
    func fetchInboxWithUnreadCount(accountId: String, completion: @escaping (Result<([Chat], Int), Error>) -> Void) {
        fetchInbox(accountId: accountId) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let chats):
                let group = DispatchGroup()
                var totalUnreadCount = 0

                for chat in chats {
                    group.enter()
                    FSChatManager.shared.fetchMessages(accountId: accountId, chatId: chat.id.uuidString) { result in
                        switch result {
                        case .failure(let error):
                            print("Error fetching messages: \(error)")
                        case .success(let messages):
                            let unreadCount = messages.filter { !$0.isRead && $0.senderId != accountId }.count
                            totalUnreadCount += unreadCount
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    completion(.success((chats, totalUnreadCount)))
                }
            }
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
        // First, get the username of the user who is adding the chat
        self.db.collection("Accounts").document(accountId).getDocument { [weak self] (documentSnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = documentSnapshot, let initiatorUsername = document.data()?["username"] as? String else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Account not found or username missing"])))
                return
            }

            // Continue with adding the chat
            self?.processAddChat(chat, initiatorUsername: initiatorUsername, initiatorAccountId: accountId, completion: completion)
        }
    }

    private func processAddChat(_ chat: Chat, initiatorUsername: String, initiatorAccountId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var accountIds: [String: String] = [:] // Mapping usernames to account IDs
        var firstError: Error?

        // Fetch account IDs for each participant
        for username in chat.participants {
            group.enter()
            self.fetchAccountIdForUsername(username: username) { result in
                switch result {
                case .failure(let error):
                    if firstError == nil {
                        firstError = error
                    }
                case .success(let fetchedAccountId):
                    accountIds[username] = fetchedAccountId
                }
                group.leave()
            }
        }

        // After fetching all account IDs, add chat to each participant's Inbox
        group.notify(queue: .main) {
            if let error = firstError {
                completion(.failure(error))
                return
            }

            // Process chat for non-initiator participants
            for (username, participantAccountId) in accountIds where participantAccountId != initiatorAccountId {
                group.enter()

                var modifiedChat = chat
                // Include the initiator's username and exclude the current participant's username
                modifiedChat.participants = chat.participants.filter { $0 != username } + [initiatorUsername]

                let data = self.convertChatToData(modifiedChat)
                self.db.collection("Accounts").document(participantAccountId).collection("Inbox").addDocument(data: data) { error in
                    if let error = error, firstError == nil {
                        firstError = error
                    }
                    group.leave()
                }
            }

            // Add the chat to the initiator's own Inbox
            group.enter()
            var initiatorChat = chat
            // Exclude the initiator's username from the participants list
            initiatorChat.participants = chat.participants.filter { $0 != initiatorUsername }
            let initiatorData = self.convertChatToData(initiatorChat)
            self.db.collection("Accounts").document(initiatorAccountId).collection("Inbox").addDocument(data: initiatorData) { error in
                if let error = error, firstError == nil {
                    firstError = error
                }
                group.leave()
            }

            group.notify(queue: .main) {
                if let error = firstError {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }


    private func fetchAccountIdForUsername(username: String, completion: @escaping (Result<String, Error>) -> Void) {
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

    private func convertChatToData(_ chat: Chat) -> [String: Any] {
        let data: [String: Any] = [
            "id": chat.id.uuidString,
            "participants": chat.participants,
            "lastMessage": chat.lastMessage ?? "",
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
