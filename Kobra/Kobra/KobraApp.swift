//
//  KobraApp.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/15/23.
//

import SwiftUI
import Firebase
import UIKit

@main
struct KobraApp: App {
    @StateObject var authenticationViewModel = AuthenticationViewModel()
    @StateObject var settingsViewModel = SettingsViewModel()
    @StateObject var kobraViewModel = KobraViewModel()
    @StateObject var notificationViewModel = NotificationViewModel()
    @StateObject var homePageViewModel = HomePageViewModel()
    @StateObject var accountViewModel = AccountViewModel()
    @StateObject var discoverViewModel = DiscoverViewModel()
    @StateObject var inboxViewModel = InboxViewModel()
    @StateObject var foodViewModel = FoodViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authenticationViewModel.isAuthenticated {
                    MainAppView()
                        .environmentObject(authenticationViewModel)
                        .environmentObject(settingsViewModel)
                        .environmentObject(kobraViewModel)
                        .environmentObject(notificationViewModel)
                        .environmentObject(homePageViewModel)
                        .environmentObject(accountViewModel)
                        .environmentObject(discoverViewModel)
                        .environmentObject(inboxViewModel)
                } else {
                    AuthenticationView()
                        .environmentObject(authenticationViewModel)
                        .onAppear(){
                            notificationViewModel.resetData()
                            inboxViewModel.resetData()
                            kobraViewModel.resetData()
                            accountViewModel.resetData()
                            settingsViewModel.resetData()
                            discoverViewModel.resetData()
                            foodViewModel.resetData()
                        }
                }
            }
            .onAppear {
                authenticationViewModel.startListening()
            }
            .onDisappear {
                authenticationViewModel.stopListening()
            }
        }
    }
}
