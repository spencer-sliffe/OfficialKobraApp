//
//  HomePageViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//
import Foundation
import SwiftUI

class HomePageViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var showAuthenticationView = false
    func signIn() {
        isSignedIn = true
        showAuthenticationView = false
    }
    func signOut() {
        isSignedIn = false
        showAuthenticationView = true
    }
}
