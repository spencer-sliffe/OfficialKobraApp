//  FollowerView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 6/30/23.

import Foundation
import SwiftUI

struct FollowerView: View {
    @StateObject var viewModel: AccountProfileViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        ForEach(viewModel.followers, id: \.self) { follower in
                            NavigationLink(destination: AccountProfileView(accountId: follower)
                                .environmentObject(settingsViewModel)
                                .environmentObject(homePageViewModel)
                                .environmentObject(kobraViewModel)) {
                                FollowCell(accountId: follower)
                            }
                        }
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            gradientOptions[settingsViewModel.gradientIndex].0,
                            gradientOptions[settingsViewModel.gradientIndex].1
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
        }
    }
}
