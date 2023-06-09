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

import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var username = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isSignIn = true
    @Published var isLoading1 = false
    @Published var isError = false
    @Published var errorMessage = ""
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @Published var user: User?
    
    let signedOut = PassthroughSubject<Void, Never>()
    
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

        guard username.count >= 5 else {
            isError = true
            errorMessage = "Username must be at least 5 characters long."
            isLoading1 = false
            return
        }
        
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            isError = true
            errorMessage = "Please fill out all fields."
            isLoading1 = false
            return
        }

        guard password == confirmPassword else {
            isError = true
            errorMessage = "Passwords do not match."
            isLoading1 = false
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.isLoading1 = false
            if let error = error {
                self.isError = true
                self.errorMessage = error.localizedDescription
                return
            }

            let db = Firestore.firestore()
            db.collection("Accounts").document(authResult!.user.uid).setData([
                "email": self.email,
                "subscription": false,
                "username": self.username,
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
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            signedOut.send()
            isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
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

