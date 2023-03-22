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
    @Published var isLoading = false
    @Published var searchText = ""
    private let firestoreManager: FirestoreManager
    private var cancellables = Set<AnyCancellable>()
    private var listener: ListenerRegistration?
    
    init(firestoreManager: FirestoreManager = FirestoreManager.shared) {
        self.firestoreManager = firestoreManager
    }
    
    var currentUserEmail: String {
        return Auth.auth().currentUser?.email ?? ""
    }

    func fetchChats() {
        isLoading = true
        listener?.remove() // Remove any existing listener
        print("Fetching chats for user with email: \(currentUserEmail)")
        firestoreManager.observeChats(forUserWithEmail: currentUserEmail)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false // Set isLoading to false
                switch completion {
                case .failure(let error):
                    print("Failed to fetch chats: \(error.localizedDescription)")
                case .finished:
                    print("Successfully fetched chats for user with email: \(self.currentUserEmail)")
                }
            }, receiveValue: { [weak self] chats in
                print("Received \(chats.count) chats for user with email: \(self?.currentUserEmail ?? "")")
                self?.chats = chats
            })
            .store(in: &cancellables)
    }


    func addChat(withUserEmail userEmail: String, completion: @escaping (Result<Chat, Error>) -> Void) {
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

    func observeUnreadMessageCount(forChat chat: Chat, completion: @escaping (Result<Int, Error>) -> Void) -> ListenerRegistration {
        return firestoreManager.observeUnreadMessageCount(forChat: chat, currentUserEmail: currentUserEmail, completion: completion)
    }

    func markMessagesAsRead(forChat chat: Chat) {
        firestoreManager.markMessagesAsRead(forChat: chat, currentUserEmail: currentUserEmail)
    }
}

