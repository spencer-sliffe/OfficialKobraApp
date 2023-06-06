//
// AuthenticationViewModel.swift
// Kobra
//
// Created by Spencer Sliffe on 3/2/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isSignIn = true
    @Published var isLoading1 = false
    @Published var isError = false
    @Published var errorMessage = ""
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @Published var user: User?

    let signedOut = PassthroughSubject<Void, Never>()
    func signOut() {
        do {
            try Auth.auth().signOut()
            signedOut.send()
            isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    func signIn() {
        isLoading1 = true
        isError = false
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            self.isLoading1 = false
            if let error = error {
                self.isError = true
                self.errorMessage = error.localizedDescription
                return
            }
            self.user = authResult?.user
            self.isAuthenticated = true
        }
    }
    
    func signUp() {
        isLoading1 = true
        isError = false
        errorMessage = ""
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            self.isError = true
            self.errorMessage = "Please fill out all fields."
            self.isLoading1 = false
            return
        }
        guard password == confirmPassword else {
            self.isError = true
            self.errorMessage = "Passwords do not match."
            self.isLoading1 = false
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.isLoading1 = false
            if let error = error {
                self.isError = true
                self.errorMessage = error.localizedDescription
                return
            }
            // Add the user's account information to the "Accounts" collection on Firebase
            let db = Firestore.firestore()
            db.collection("Accounts").document(authResult!.user.uid).setData([
                "email": self.email,
                "subscription": false,
                "package": "",
                "followers": [String](),
                "following": [String]()
            ]) { error in
                if let error = error {
                    self.isError = true
                    self.errorMessage = error.localizedDescription
                } else {
                    self.user = authResult?.user
                    self.isAuthenticated = true
                }
            }
        }
    }
    
    func startListening() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    func stopListening() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
