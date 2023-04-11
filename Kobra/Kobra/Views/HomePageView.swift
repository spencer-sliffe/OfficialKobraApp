//
//  HomePageView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//
import SwiftUI
import Foundation

struct HomePageView: View {
    @State private var selectedTab = 2
    @ObservedObject var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if !authViewModel.isAuthenticated {
                    AuthenticationView(authViewModel: authViewModel)
                } else {
                    TabView(selection: $selectedTab) {
                        MarketPlaceView()
                            .tag(0)
                        AccountView(authViewModel: authViewModel)
                            .tag(1)
                        KobraView()
                            .tag(2)
                        InboxView(viewModel: InboxViewModel())
                            .tag(3)
                        PackageView()
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .navigationBarHidden(true)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.black, .blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

