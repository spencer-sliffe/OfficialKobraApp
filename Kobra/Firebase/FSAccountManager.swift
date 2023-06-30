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
        let data: [String: Any] = [
            "id": account.id,
            "email": account.email,
            "username": account.username,
            "subscription": account.subscription,
            "profilePicture": account.profilePicture?.absoluteString ?? "",
            "followers": account.followers,
            "following": account.following,
            "package": account.package,
            "bio": account.bio ?? ""
        ]
        
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
            "username": account.username,
            "subscription": account.subscription,
            "profilePicture": account.profilePicture?.absoluteString ?? "",
            "followers": account.followers,
            "following": account.following,
            "package": account.package,
            "bio": account.bio ?? ""
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
    
    private func createAccountFrom(data: [String: Any]) -> Account {
        let id = data["id"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let username = data["username"] as? String ?? ""
        let subscription = data["subscription"] as? Bool ?? false
        let package = data["package"] as? String ?? ""
        let profilePicture = data["profilePicture"] as? String
        let followers = data["followers"] as? [String] ?? []
        let following = data["following"] as? [String] ?? []
        let bio = data["bio"] as? String ?? ""
        
        return Account(id: id, email: email, username: username, subscription: subscription, package: package, profilePicture: profilePicture, followers: followers, following: following, bio: bio)
    }
    
    func deleteProfilePicture(imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: imageURL)
        
        storageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func uploadProfilePicture(_ image: UIImage, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let url = url {
                    self.updateProfilePictureURL(userId: userId, imageURL: url.absoluteString, completion: completion)
                } else {
                    completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }
    
    // New function to update the profile picture URL of an account
    private func updateProfilePictureURL(userId: String, imageURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        let accountRef = db.collection(accountCollection).document(userId)
        accountRef.updateData([
            "profilePicture": imageURL
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(imageURL))
            }
        }
    }
    
    func updateBio(userId: String, bio: String, completion: @escaping (Result<String, Error>) -> Void) {
           let accountRef = db.collection(accountCollection).document(userId)
           accountRef.updateData([
               "bio": bio
           ]) { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(bio))
               }
           }
       }
    
    func updateUsername(userId: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        let accountRef = db.collection(accountCollection).document(userId)
        accountRef.updateData([
            "username": username
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(username))
            }
        }
    }
}
