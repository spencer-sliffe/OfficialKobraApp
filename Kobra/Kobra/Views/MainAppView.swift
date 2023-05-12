//
//  MainAppView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/2/23
//

import Foundation
import SwiftUI
import Firebase

struct MainAppView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                HomePageView().environmentObject(settingsViewModel)
            } else {
                AuthenticationView(authViewModel: authViewModel)
            }
        }
        .onAppear {
            authViewModel.startListening()
        }
        .onDisappear {
            authViewModel.stopListening()
        }
    }
}
