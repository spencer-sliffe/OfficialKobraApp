//
//  FollowerView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 6/30/23.
//

import Foundation
import SwiftUI

struct FollowerView: View {
    @ObservedObject var viewModel: AccountProfileViewModel

    var body: some View {
        List {
            ForEach(viewModel.followers) { follower in
                FollowCell(accountId: follower)
            }
        }
    }
}



