//
//  InboxViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/18/23.
//

import Foundation
import Combine
import FirebaseAuth

class InboxViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var unreadMessagesCount: Int = 0
    @Published var isLoading: Bool = true
    private let inboxManager = FSInboxManager.shared
    
    init() {
        fetchInbox()
    }
    
    func fetchInbox() {
        isLoading = true
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            isLoading = false
            return
        }
        
        inboxManager.fetchInboxWithUnreadCount(accountId: user.uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (chats, unreadCount)):
                    self?.chats = chats
                    self?.unreadMessagesCount = unreadCount
                case .failure(let error):
                    print("Error fetching inbox: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }
    
    func addChat(participants: [String], chatName: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        
        let newChat = Chat(id: UUID(), participants: participants, lastMessage: "", timestamp: Date(), profilePicture: "")
        
        inboxManager.addChat(newChat, accountId: user.uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.chats.append(newChat)
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    func deleteChat(chatId: String) {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        inboxManager.deleteChat(chatId: chatId, accountId: user.uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.chats.removeAll { $0.id.uuidString == chatId }
                case .failure(let error):
                    print("Error deleting chat: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkIfUserNameValid(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        inboxManager.checkIfUserNameValid(username: username) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func resetData() {
        chats = []
        unreadMessagesCount = 0
        isLoading = false
    }
}
