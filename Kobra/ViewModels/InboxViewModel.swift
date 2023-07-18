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
    @Published var isLoading: Bool = true
    private let inboxManager = FSInboxManager.shared
    
    init(){
        fetchInbox()
    }
    
    func fetchInbox() {
        isLoading = true
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            isLoading = false
            return
        }
        inboxManager.fetchInbox(accountId: user.uid) { [weak self]
            result in
            DispatchQueue.main.async {
                switch result {
                case .success(let chats):
                    self?.chats = chats
                case .failure(let error):
                    print("error fetching notifications: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }
}
