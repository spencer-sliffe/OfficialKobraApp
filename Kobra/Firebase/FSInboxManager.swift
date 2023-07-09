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
    
    /*func fetchInbox(accountId: String, completion: @escaping (Result<[Chat], Error>) -> Void){
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
    }*/
    
   /* struct Inbox: Identifiable {
     var id = UUID()
     var accountId: String
     var chats: [Chat]
     
     init(id: UUID = UUID(), accountId: String, chats: [Chat]) {
         self.id = id
         self.accountId = accountId
         self.chats = chats
     }
 }*/
    
    /*private func createChatFrom(data: [String: Any]) -> Chat {
        let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        let accountId = data["accountId"] as? String ?? ""
        let lastMessage = data["lastMessage"] as? Message ?? nil
        //let
    }*/
}
