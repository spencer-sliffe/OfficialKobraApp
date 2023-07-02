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

    var body: some View {
        List {
            ForEach(viewModel.following) { followed in
                FollowCell(accountId: followed)
            }
        }
    }
}

