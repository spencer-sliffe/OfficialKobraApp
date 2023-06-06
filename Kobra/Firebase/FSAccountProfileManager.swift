//
//  FSAccountProfileManager.swift
//  Kobra
//
//  Created by Spencer SLiffe on 6/6/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

class FSAccountProfileManager {
    private init() {}
    static let shared = FSAccountProfileManager()
    private let db = Firestore.firestore()
    private let accountCollection = "Accounts"
    
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

        db.collection(accountCollection).addDocument(data: data) { error in
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
    
    func followAccount(accountId: String, followerId: String, completion: @escaping (Result<Void, Error>) -> Void) {
           let accountRef = db.collection(accountCollection).document(accountId)

           accountRef.updateData(["followers": FieldValue.arrayUnion([followerId])]) { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
       }
       
       func unfollowAccount(accountId: String, followerId: String, completion: @escaping (Result<Void, Error>) -> Void) {
           let accountRef = db.collection(accountCollection).document(accountId)

           accountRef.updateData(["followers": FieldValue.arrayRemove([followerId])]) { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
       }
}
