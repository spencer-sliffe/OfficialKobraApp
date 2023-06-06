//
//  DiscoverViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/18/23.
//

import Foundation
import Combine
import Firebase

class DiscoverViewModel: ObservableObject {
    @Published var accounts = [Account]()
    private var db = Firestore.firestore()
    
    init() {
        fetchAccounts()
    }
    
    func fetchAccounts() {
        db.collection("Accounts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let newAccount = Account(
                        id: document.documentID, // use documentID as the account's id
                        email: data["email"] as? String ?? "",
                        subscription: data["subscription"] as? Bool ?? false,
                        packageData: data["package"] as? [String: Any],
                        profilePicture: data["profilePicture"] as? String,
                        followers: data["followers"] as? [String] ?? [""],
                        following: data["following"] as? [String] ?? [""]
                    )
                    self.accounts.append(newAccount)
                }
            }
        }
    }
    
    func searchAccounts(query: String) {
        if query.isEmpty {
            fetchAccounts()
        } else {
            self.accounts = self.accounts.filter({$0.email.lowercased().contains(query.lowercased())})
        }
    }
}


