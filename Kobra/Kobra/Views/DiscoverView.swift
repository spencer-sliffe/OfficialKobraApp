//
//  DiscoverView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/18/23.
//

import Foundation
import SwiftUI

struct DiscoverView: View {
    @StateObject var viewModel = DiscoverViewModel()
    @State var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            AccountSearchBar(text: $searchText)
            ScrollView {
                // Only show the list when searchText is not empty
                if !searchText.isEmpty {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.accounts.filter({$0.email.lowercased().contains(searchText.lowercased())}), id: \.id) { account in
                            NavigationLink(
                                destination: AccountProfileView(accountId: account.id),
                                label: {
                                    AccountCell(account: account)
                                })
                        }
                    }
                }
            }
            .onAppear {
                if viewModel.accounts.isEmpty {
                    viewModel.fetchAccounts()
                }
            }
            .onChange(of: searchText) { newValue in
                viewModel.searchAccounts(query: newValue)
            }
        }
    }
}
