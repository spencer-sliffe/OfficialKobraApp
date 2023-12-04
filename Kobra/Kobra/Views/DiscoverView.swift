//
//  DiscoverView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/18/23.
//

import Foundation
import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var viewModel: DiscoverViewModel
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    @State var searchText = ""
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            AccountSearchBar(text: $searchText)
            ScrollView {
                // Only show the list when searchText is not empty
                if !searchText.isEmpty {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.searchResults.filter({$0.username.lowercased().contains(searchText.lowercased())}), id: \.id) { account in
                            NavigationLink(
                                destination: AccountProfileView(accountId: account.id)
                                    .environmentObject(homePageViewModel)
                                    .environmentObject(settingsViewModel)
                                    .environmentObject(kobraViewModel)
                                    .isInView { isInView in
                                        // Perform action depending on whether the view is in view or not
                                        if isInView {
                                            homePageViewModel.accProViewActive = true
                                        } else {
                                            print("AccountProfileView is not in view")
                                            homePageViewModel.accProViewActive = false
                                        }
                                    }
                                    .onAppear {
                                        // Clear out the search state when navigating away
                                        viewModel.clearSearchResults()
                                        hideKeyboard()
                                    },
                                label: {
                                    AccountCell(account: account)
                                })
                        }
                    }
                } else {
                    //GeometryReader { geometry in
                    Spacer()
                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 10) {
                                ForEach(viewModel.posts.sorted(by: { $0.likes > $1.likes })) { post in
                                    DiscoverPostRow(post: post)
                                        .environmentObject(kobraViewModel)
                                        .environmentObject(homePageViewModel)
                                        .environmentObject(settingsViewModel)
                                        .background(Color.clear)
                                }
                            }
                        }
                        .refreshable {
                            viewModel.fetchPosts()
                        }
                        .padding(.trailing, 1)  // Add some padding to the right side of the ScrollView
                        .background(Color.clear)
                        .overlay(  // Add an overlay to the right side of the ScrollView
                            Color.clear
                                .frame(width: 1)  // Set width to the same value as the padding above
                                .edgesIgnoringSafeArea(.all), alignment: .trailing
                        )
                    //}
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
    // function to hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

