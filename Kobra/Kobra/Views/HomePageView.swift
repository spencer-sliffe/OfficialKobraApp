//
//  HomePageView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//

import SwiftUI
import Firebase

struct HomePageView: View {
    @State private var selectedTab = "home"
    @State private var totalUnreadMessages = 0
    @ObservedObject var inboxViewModel = InboxViewModel()
    @State private var isSignedIn = true
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.black, .blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    TabView(selection: $selectedTab) {
                        AccountView(authViewModel: authViewModel) // Pass the view model down to the AccountView
                            .tag("account")
                        InboxView(viewModel: InboxViewModel())
                            .tag("inbox")
                        KobraView()
                            .tag("home")
                        MarketPlaceView()
                            .tag("market")
                        PackageView()
                            .tag("package")
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    Spacer()
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            selectedTab = "account"
                        }) {
                            VStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: selectedTab == "account" ? 35 : 30))
                            }
                        }
                        .foregroundColor(selectedTab == "account" ? .white : .gray)
                        
                        Spacer()
                        
                        Button(action: {
                            selectedTab = "inbox"
                            totalUnreadMessages = inboxViewModel.unreadMessageCounts.values.reduce(0, +)
                        }) {
                            ZStack {
                                VStack {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: selectedTab == "inbox" ? 35 : 30))
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
                        
                        Spacer()
                        
                        Button(action: {
                            selectedTab = "home"
                        }) {
                            VStack {
                                Image(selectedTab == "home" ? "home" : "home2")
                                    .resizable()
                                    .frame(width: selectedTab == "home" ? 50 : 50, height: selectedTab == "home" ? 50 : 50)
                            }
                        }
                        .foregroundColor(selectedTab == "home" ? .white : .gray)
                        
                        Spacer()
                        
                        Button(action: {
                            selectedTab = "market"
                        }) {
                            VStack {
                                Image(systemName: "cart.fill")
                                    .font(.system(size: selectedTab == "market" ? 35 : 30))
                            }
                        }
                        .foregroundColor(selectedTab == "market" ? .white : .gray)
                        
                        Spacer()
                        
                        Button(action: {
                            selectedTab = "package"
                        }) {
                            VStack {
                                Image(systemName: "shippingbox.fill")
                                    .font(.system(size: selectedTab == "package" ? 35 : 30))
                            }
                        }
                        .foregroundColor(selectedTab == "package" ? .white : .gray)
                        
                    }
                    .padding(.horizontal)
                    .ignoresSafeArea()
                    
                }
            }
            .navigationBarHidden(selectedTab != "inbox")
            .onChange(of: isSignedIn) { signedIn in
                if !signedIn {
                    selectedTab = "account"
                }
            }
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(inboxViewModel: InboxViewModel())
    }
}

