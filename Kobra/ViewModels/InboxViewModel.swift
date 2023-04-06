//
//  InboxViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/18/23.
//

import Foundation
import FirebaseFirestore
import Firebase
import Combine

class InboxViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var isLoading = true
    @Published var searchText = ""
    @Published var unreadMessageCounts: [String: Int] = [:]
    private let firestoreManager: FirestoreManager
    private var cancellables = Set<AnyCancellable>()
    private var listener: ListenerRegistration?
    private var listeners: [ListenerRegistration] = []
    
    init(firestoreManager: FirestoreManager = FirestoreManager.shared) {
        self.firestoreManager = firestoreManager
        fetchChats()
        observeUnreadMessageCounts(forChats: chats)
    }
    
    var currentUserEmail: String {
        return Auth.auth().currentUser?.email ?? ""
    }
    
    func fetchChats() {
        isLoading = true
        print("Fetching chats for user with email: \(currentUserEmail)")
        let chatsListener = firestoreManager.observeChats(forUserWithEmail: currentUserEmail) { [weak self] (result: Result<[Chat], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Failed to fetch chats: \(error.localizedDescription)")
                case .success(let chats):
                    print("Successfully fetched chats for user with email: \(self?.currentUserEmail ?? "")")
                    self?.chats = chats
                    self?.observeUnreadMessageCounts(forChats: chats)
                }
                self?.isLoading = false
                print("isLoading is getting set to false now")
            }
        }
        if let listener = chatsListener {
            listeners.append(listener)
        }
    }
    
    deinit {
        for listener in listeners {
            listener.remove()
        }
    }
    
    func addChat(withUserEmail userEmail: String, completion: @escaping (Result<Chat, Error>) -> Void) {
        // Check if a chat between the two users already exists
        if chats.contains(where: { $0.participants.contains(userEmail) }) {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "A chat already exists with this user."])))
            return
        }
        firestoreManager.createChat(withUserWithEmail: userEmail, currentUserEmail: currentUserEmail) { [weak self] result in
            switch result {
            case .success(let chat):
                // Make a copy of the chats array and append the new chat
                var updatedChats = self?.chats ?? []
                updatedChats.append(chat)
                // Assign the updated array back to the original property
                self?.chats = updatedChats
                completion(.success(chat))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func observeUnreadMessageCounts(forChats chats: [Chat]) {
        for chat in chats {
            let listener = observeUnreadMessageCount(forChat: chat) { [weak self] result in
                switch result {
                case .success(let count):
                    var counts = self?.unreadMessageCounts ?? [:]
                    counts[chat.id] = count
                    self?.unreadMessageCounts = counts
                case .failure(let error):
                    print("Failed to fetch unread message count: \(error.localizedDescription)")
                }
            }
            listeners.append(listener)
        }
    }

    func observeUnreadMessageCount(forChat chat: Chat, completion: @escaping (Result<Int, Error>) -> Void) -> ListenerRegistration {
        return firestoreManager.observeUnreadMessageCount(forChat: chat, currentUserEmail: currentUserEmail, completion: completion)
    }
    
    func markMessagesAsRead(forChat chat: Chat) {
        firestoreManager.markMessagesAsRead(forChat: chat, currentUserEmail: currentUserEmail)
    }
}
