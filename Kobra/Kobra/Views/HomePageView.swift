//
//  HomePageView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//

import SwiftUI
import Firebase

struct HomePageView: View {
    @State private var selectedTab = "account"

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                    TabView(selection: $selectedTab) {
                        AccountView()
                            .tag("account")
                        PackageView()
                            .tag("package")
                        InboxView(viewModel: InboxViewModel())
                                .tag("inbox")
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .navigationBarHidden(true)


                    Spacer()

                    HStack(spacing: 0) {
                        Button(action: {
                            selectedTab = "account"
                        }) {
                            VStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 30))
                                Text("Account")
                            }
                        }
                        .foregroundColor(selectedTab == "account" ? .white : .gray)

                        Spacer()

                        Button(action: {
                            selectedTab = "package"
                        }) {
                            VStack {
                                Image(systemName: "shippingbox.fill")
                                    .font(.system(size: 30))
                                Text("Package")
                            }
                        }
                        .foregroundColor(selectedTab == "package" ? .white : .gray)

                        Spacer()

                        Button(action: {
                            selectedTab = "inbox"
                        }) {
                            VStack {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 30))
                                Text("Chat")
                            }
                        }
                        .foregroundColor(selectedTab == "inbox" ? .white : .gray)
                    }
                    .padding(.horizontal)
                }
            }.navigationTitle(selectedTab.capitalized)
            
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}


