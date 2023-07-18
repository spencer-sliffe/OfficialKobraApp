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
            List {
                ForEach(viewModel.following, id: \.self) { followed in
                    NavigationLink(destination: AccountProfileView(accountId: followed)) {
                        FollowCell(accountId: followed)
                    }
                }
            }
        }
    }
}

