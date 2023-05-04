//
// AccountViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//
import Firebase
import SwiftUI

class AccountViewModel: ObservableObject {
    @Published var account: Account?
    @Published var isLoading3 = true
    let dataManager = FSAccountManager()
    @Published var userPosts: [Post] = []
    @Published var isLoading = true

    init() {
        fetchAccount()
    }
    
    func fetchAccount() {
        guard let user = Auth.auth().currentUser else {
            print("Error: No user is currently signed in.")
            return
        }
        let userEmail = user.email ?? ""
        let emailComponents = userEmail.split(separator: "@")
        let displayName = String(emailComponents[0]).uppercased()
        // Create a DispatchGroup
        let dispatchGroup = DispatchGroup()
        
        // Enter the DispatchGroup for fetching user posts
        dispatchGroup.enter()
        FSPostManager.shared.fetchUserPosts(userEmail: displayName) { result in
            switch result {
            case .success(let posts):
                DispatchQueue.main.async {
                    self.userPosts = posts
                }
            case .failure(let error):
                print("Error fetching user posts: \(error.localizedDescription)")
            }
            // Leave the DispatchGroup after fetching user posts
            dispatchGroup.leave()
        }

        // Enter the DispatchGroup for fetching account data
        dispatchGroup.enter()
        let db = Firestore.firestore()
        let ref = db.collection("Accounts").document(user.uid)
        ref.getDocument { (document, error) in
            guard let document = document, document.exists, error == nil else {
                print("Error fetching account data: \(error?.localizedDescription ?? "unknown error")")
                dispatchGroup.leave()
                return
            }
            let data = document.data()!
            let email = user.email ?? ""
            let subscription = data["subscription"] as? Bool ?? false
            var account = Account(id: user.uid, email: email, subscription: subscription, packageData: nil, profilePicture: nil)
            if let packageId = data["packageId"] as? String {
                let packageRef = db.collection("Packages").document(packageId)
                packageRef.getDocument { (packageDocument, packageError) in
                    guard let packageDocument = packageDocument, packageDocument.exists, packageError == nil else {
                        print("Error fetching package data: \(packageError?.localizedDescription ?? "unknown error")")
                        dispatchGroup.leave()
                        return
                    }
                    let packageData = packageDocument.data()!
                    let package = Package(id: packageDocument.documentID, name: packageData["name"] as! String, price: packageData["price"] as! Double)
                    account.package = package
                    self.account = account
                    
                    // Leave the DispatchGroup after fetching account data
                    dispatchGroup.leave()
                }
            } else {
                self.account = account
                
                // Leave the DispatchGroup when there's no package data to fetch
                dispatchGroup.leave()
            }
        }
        
        // Set isLoading to false after both account data and user posts have been fetched
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
}
