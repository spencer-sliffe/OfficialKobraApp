//
//  InboxView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/18/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct InboxView: View {
    @ObservedObject var viewModel = InboxViewModel()
    @EnvironmentObject var homePageViewModel: HomePageViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
               Spacer()
               ProgressView()
               Spacer()
            } else {
                ScrollView {
                    ForEach(viewModel.chats.sorted(by: { $0.timestamp > $1.timestamp })) { chat in
                        ChatCell(chat: chat)
                    }
                }
                .refreshable {
                    viewModel.fetchInbox()
                }
            }
        }
    }
}
