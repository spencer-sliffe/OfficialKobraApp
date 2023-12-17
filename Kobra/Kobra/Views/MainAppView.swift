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
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var homePageViewModel: HomePageViewModel
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    @EnvironmentObject var inboxViewModel: InboxViewModel
    
    var body: some View {
        HomePageView()
            .environmentObject(settingsViewModel)
            .environmentObject(kobraViewModel)
            .environmentObject(notificationViewModel)
            .environmentObject(authViewModel)
            .environmentObject(homePageViewModel)
            .environmentObject(accountViewModel)
            .environmentObject(discoverViewModel)
            .environmentObject(inboxViewModel)
            .onAppear {
                kobraViewModel.fetchPosts()
                notificationViewModel.fetchNotifications()
                discoverViewModel.fetchPosts()
                discoverViewModel.fetchAccounts()
                accountViewModel.fetchAccount()
            }
    }
}
