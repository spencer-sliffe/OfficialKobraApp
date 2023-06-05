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
    @Published var viewedUserPosts: [Post] = [] // Add this line

    private var cancellables: Set<AnyCancellable> = [] // Add this line

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
                        id: data["id"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        subscription: data["subscription"] as? Bool ?? false,
                        packageData: data["package"] as? [String: Any],
                        profilePicture: data["profilePicture"] as? String
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
    
    func follow(account: Account, followerId: String) {
        let docRef = db.collection("accounts").document(account.id)
        docRef.updateData([
            "followers": FieldValue.arrayUnion([followerId])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func unfollow(account: Account, followerId: String) {
        let docRef = db.collection("accounts").document(account.id)
        docRef.updateData([
            "followers": FieldValue.arrayRemove([followerId])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func fetchViewedUserPosts(viewedUserId: String) {
            fetchUserPosts(userEmail: viewedUserId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                }, receiveValue: { userPosts in
                    self.viewedUserPosts = userPosts
                })
                .store(in: &cancellables)
        }

        private func fetchUserPosts(userEmail: String) -> Future<[Post], Error> {
            Future { promise in
                let emailComponents = userEmail.split(separator: "@")
                let displayName = String(emailComponents[0])
                FSPostManager.shared.fetchUserPosts(userEmail: displayName) { result in
                    switch result {
                    case .success(let posts):
                        promise(.success(posts))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
    
    func isFollowing(account: Account, completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let docRef = db.collection("accounts").document(account.id)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let followers = data["followers"] as? [String] ?? []
                completion(followers.contains(currentUserId))
            } else {
                completion(false)
            }
        }
    }


}

