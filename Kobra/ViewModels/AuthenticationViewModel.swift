//
// AuthenticationViewModel.swift
// Kobra
//
// Created by Spencer Sliffe on 3/2/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isSignIn = true
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage = ""
    @Published var isAuthenticated = false
    @Published var user: User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    func signIn() {
        isLoading = true
        isError = false
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            self.isLoading = false
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
        isLoading = true
        isError = false
        errorMessage = ""
        
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            self.isError = true
            self.errorMessage = "Please fill out all fields."
            self.isLoading = false
            return
        }
        
        guard password == confirmPassword else {
            self.isError = true
            self.errorMessage = "Passwords do not match."
            self.isLoading = false
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.isLoading = false
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
                "package": ""
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
