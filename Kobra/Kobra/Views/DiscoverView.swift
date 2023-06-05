//
//  DiscoverView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/18/23.
//

import Foundation
import SwiftUI

struct DiscoverView: View {
    @StateObject var viewModel = DiscoverViewModel()
    @State var searchText = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding()
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.accounts.filter({"\($0)".contains(searchText) || searchText.isEmpty}), id: \.id) { account in
                        NavigationLink(
                            destination: AccountProfileView(account: account),
                            label: {
                                AccountCell(account: account)
                                    .padding(.vertical, 8)
                            })
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

