//
//  FollowingView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 6/30/23.
//

import Foundation
import SwiftUI

struct FollowingView: View {
    @StateObject var viewModel: AccountProfileViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        ForEach(viewModel.following, id: \.self) { followed in
                            NavigationLink(destination: AccountProfileView(accountId: followed)
                                .environmentObject(settingsViewModel)
                                .environmentObject(homePageViewModel)
                                .environmentObject(kobraViewModel)) {
                                FollowCell(accountId: followed)
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

