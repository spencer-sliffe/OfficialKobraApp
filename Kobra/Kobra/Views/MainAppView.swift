//
//  MainAppView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/2/23.
//

import Foundation
import SwiftUI
import Firebase

struct MainAppView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @ObservedObject var settingsViewModel = SettingsViewModel()
    @ObservedObject private var kobraViewModel = KobraViewModel()
    @ObservedObject private var notificationViewModel = NotificationViewModel()
    @ObservedObject private var homePageViewModel = HomePageViewModel()
    @ObservedObject private var accountViewModel = AccountViewModel()
    @ObservedObject private var discoverViewModel = DiscoverViewModel()
    @ObservedObject private var inboxViewModel = InboxViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                HomePageView()
                    .environmentObject(settingsViewModel)
                    .environmentObject(kobraViewModel)
                    .environmentObject(notificationViewModel)
                    .environmentObject(authViewModel)
                    .environmentObject(homePageViewModel)
                    .environmentObject(accountViewModel)
                    .environmentObject(discoverViewModel)
                    .environmentObject(inboxViewModel)
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            authViewModel.startListening()
            kobraViewModel.fetchPosts()
            notificationViewModel.fetchNotifications()
            discoverViewModel.fetchPosts()
            discoverViewModel.fetchAccounts()
            accountViewModel.fetchAccount()
        }
        .onDisappear {
            authViewModel.stopListening()
        }
    }
}
