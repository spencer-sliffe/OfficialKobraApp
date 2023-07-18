//
//  FollowingView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 6/30/23.
//

import Foundation
import SwiftUI

struct FollowingView: View {
    @ObservedObject var viewModel: AccountProfileViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            VStack{
                List {
                    ForEach(viewModel.following, id: \.self) { followed in
                        NavigationLink(destination: AccountProfileView(accountId: followed)) {
                            FollowCell(accountId: followed)
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

