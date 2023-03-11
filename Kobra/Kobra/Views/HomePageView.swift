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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    AccountView()
                        .tag("account")
                    PackageView()
                        .tag("package")
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .navigationBarHidden(true)
                .navigationBarTitle("")

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
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}
