//
//  DataManager.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/1/23.
//

import SwiftUI
import Firebase
import FirebaseStorage

class FSAccountManager: ObservableObject {
    static let shared = FSAccountManager()
    
    private var db = Firestore.firestore()
    
    private let accountCollection = "Accounts"
    
    var accountDidUpdate: ((Result<Account, Error>) -> Void)?
    
    func fetchAccountById(_ id: String, completion: @escaping (Result<Account, Error>) -> Void) {
        let documentRef = db.collection(accountCollection).document(id)
        documentRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, let data = document.data() {
                let account = self.createAccountFrom(data: data)
                completion(.success(account))
            }
        }
    }
    
    func follow(userToFollow: String) {
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserEmail") else { return }
        
        self.db.collection(self.accountCollection).document(currentUserId).getDocument { (document, error) in  // use self
            if let document = document, let data = document.data() {
                var following = data["following"] as? [String] ?? []
                following.append(userToFollow)
                document.reference.updateData(["following": following])
                
                self.db.collection(self.accountCollection).document(userToFollow).getDocument { (document, error) in  // use self
                    if let document = document, let data = document.data() {
                        var followers = data["followers"] as? [String] ?? []
                        followers.append(currentUserId)
                        document.reference.updateData(["followers": followers]) { error in
                            if let error = error {
                                self.accountDidUpdate?(.failure(error))  // use self
                            } else {
                                // Call the closure with the updated account
                                self.fetchAccountById(userToFollow) { result in  // use self
                                    self.accountDidUpdate?(result)  // use self
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func unfollow(userToUnfollow: String) {
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserEmail") else { return }
        
        self.db.collection(self.accountCollection).document(currentUserId).getDocument { (document, error) in  // use self
            if let document = document, let data = document.data() {
                var following = data["following"] as? [String] ?? []
                following.removeAll { $0 == userToUnfollow }
                document.reference.updateData(["following": following])
                
                self.db.collection(self.accountCollection).document(userToUnfollow).getDocument { (document, error) in  // use self
                    if let document = document, let data = document.data() {
                        var followers = data["followers"] as? [String] ?? []
                        followers.removeAll { $0 == currentUserId }
                        document.reference.updateData(["followers": followers]) { error in
                            if let error = error {
                                self.accountDidUpdate?(.failure(error))  // use self
                            } else {
                                // Call the closure with the updated account
                                self.fetchAccountById(userToUnfollow) { result in  // use self
                                    self.accountDidUpdate?(result)  // use self
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func fetchAccounts(completion: @escaping (Result<[Account], Error>) -> Void) {
        db.collection(accountCollection).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var accounts: [Account] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let account = self.createAccountFrom(data: data)
                accounts.append(account)
            }
            completion(.success(accounts))
        }
    }
    
    func addAccount(_ account: Account, completion: @escaping (Result<Void, Error>) -> Void) {
        var data: [String: Any] = [
            "id": account.id,
            "email": account.email,
            "subscription": account.subscription,
            "profilePicture": account.profilePicture?.absoluteString ?? "",
            "followers": account.followers,
            "following": account.following
        ]
        
        if let package = account.package {
            let packageData: [String : Any] = ["id": package.id, "name": package.name, "price": package.price]
            data["package"] = packageData
        }
        
        db.collection(accountCollection).document(account.id).setData(data) { error in  // updated here
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateAccount(_ account: Account, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentRef = db.collection(accountCollection).document(account.id)
        documentRef.setData([
            "email": account.email,
            "subscription": account.subscription,
            "profilePicture": account.profilePicture?.absoluteString ?? "",
            "followers": account.followers,
            "following": account.following
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteAccount(_ account: Account, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(accountCollection).document(account.id).delete() { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func uploadProfilePicture(_ image: UIImage, accountId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "AppDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to data"])))
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imagesRef = storageRef.child("images/\(accountId).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imagesRef.putData(imageData, metadata: metadata) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                imagesRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let downloadURL = url {
                        completion(.success(downloadURL.absoluteString))
                    }
                }
            }
        }
    }
    
    private func createAccountFrom(data: [String: Any]) -> Account {
        let id = data["id"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let subscription = data["subscription"] as? Bool ?? false
        let packageData = data["package"] as? [String: Any]
        let profilePicture = data["profilePicture"] as? String
        let followers = data["followers"] as? [String] ?? []
        let following = data["following"] as? [String] ?? []
        
        return Account(id: id, email: email, subscription: subscription, packageData: packageData, profilePicture: profilePicture, followers: followers, following: following)
    }

}
