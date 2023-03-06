// AuthenticationViewModel.swift
// Kobra
//
// Created by Spencer SLiffe on 3/2/23.
//

import Foundation
import Firebase

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

            self.user = authResult?.user
            self.isAuthenticated = true
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
