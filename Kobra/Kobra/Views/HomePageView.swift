//
//  HomePageView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//

import SwiftUI
import Firebase
import SwiftUI
import Firebase

struct HomePageView: View {
    @State private var selectedTab = "account"
    @State private var totalUnreadMessages = 0
    @ObservedObject var inboxViewModel = InboxViewModel()
    
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
                            totalUnreadMessages = inboxViewModel.unreadMessageCounts.values.reduce(0, +)
                        }) {
                            ZStack {
                                VStack {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 30))
                                    Text("Chat")
                                }
                                if totalUnreadMessages > 0 {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 20, height: 20)
                                        .overlay(Text("\(totalUnreadMessages)").foregroundColor(.white).font(.system(size: 12)))
                                        .offset(x: 20, y: -10)
                                }
                            }
                        }
                        .foregroundColor(selectedTab == "inbox" ? .white : .gray)
                    }
                    .padding(.horizontal)
                    
                }
            }
            .navigationBarHidden(selectedTab != "inbox")
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(inboxViewModel: InboxViewModel())
    }
}

