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
    
    
    init(firestoreManager: FirestoreManager = FirestoreManager.shared) {
        self.firestoreManager = firestoreManager
        fetchChats()
    }
    
    var currentUserEmail: String {
        return Auth.auth().currentUser?.email ?? ""
    }

    func fetchChats() {
        isLoading = true
        print("Fetching chats for user with email: \(currentUserEmail)")
        firestoreManager.observeChats(forUserWithEmail: currentUserEmail)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed to fetch chats: \(error.localizedDescription)")
                case .finished:
                    print("Successfully fetched chats for user with email: \(self.currentUserEmail)")
                }
                self.isLoading = false
                print("isLoading is getting set to false now")

            }, receiveValue: { [weak self] chats in
                print("Received \(chats.count) chats for user with email: \(self?.currentUserEmail ?? "")")
                self?.chats = chats
                self?.observeUnreadMessageCounts(forChats: chats)
            })
            .store(in: &cancellables)
    }
    
    deinit {
        listener?.remove()
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
                    self?.chats.append(chat)
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
                        self?.unreadMessageCounts[chat.id] = count
                    case .failure(let error):
                        print("Failed to fetch unread message count: \(error.localizedDescription)")
                    }
                }
                self.listener = listener
            }
        }

    func observeUnreadMessageCount(forChat chat: Chat, completion: @escaping (Result<Int, Error>) -> Void) -> ListenerRegistration {
        return firestoreManager.observeUnreadMessageCount(forChat: chat, currentUserEmail: currentUserEmail, completion: completion)
    }
    
    func markMessagesAsRead(forChat chat: Chat) {
        firestoreManager.markMessagesAsRead(forChat: chat, currentUserEmail: currentUserEmail)
    }
    
}

