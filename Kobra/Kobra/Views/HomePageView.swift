//
//  HomePageView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//
import SwiftUI
import Foundation

struct HomePageView: View {
    @State private var selectedTab = 3
    @ObservedObject var authViewModel = AuthenticationViewModel()
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    @StateObject var kobraViewModel = KobraViewModel()
    
    @ViewBuilder
    private func getView(for index: Int) -> some View {
        switch index {
        case 0:
            SettingsView(authViewModel: authViewModel)
        case 1:
            AccountView()
                .environmentObject(kobraViewModel)
        case 2:
            DiscoverView()
                .environmentObject(kobraViewModel)
        case 3:
            KobraView()
        case 4:
            InboxView(viewModel: InboxViewModel())
        case 5:
            FoodView()
        case 6:
            PackageView()
        default:
            EmptyView()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if !authViewModel.isAuthenticated {
                    AuthenticationView(authViewModel: authViewModel)
                } else {
                    VStack {
                        getView(for: selectedTab)
                            .transition(.slide)
                        HStack(spacing: 0) {
                            createTabButton(icon: "gear", tabIndex: 0)
                            createTabButton(icon: "person", tabIndex: 1)
                            createTabButton(icon: "magnifyingglass", tabIndex: 2)
                            createTabButton(icon: "house", tabIndex: 3)
                            createTabButton(icon: "envelope", tabIndex: 4)
                            createTabButton(icon: "leaf", tabIndex: 5)
                            createTabButton(icon: "shippingbox", tabIndex: 6)
                        }
                        .padding(.bottom, 16)
                        .foregroundColor(Color.white)
                    }
                    .navigationBarHidden(true)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            gradientOptions[settingsViewModel.gradientIndex].0,
                            gradientOptions[settingsViewModel.gradientIndex].1
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    @ViewBuilder
    private func createTabButton(icon: String, tabIndex: Int) -> some View {
        Button(action: {
            withAnimation { selectedTab = tabIndex }
        }) {
            Image(systemName: icon)
                .resizable()
                .frame(width: selectedTab == tabIndex ? 30 : 24, height: selectedTab == tabIndex ? 26 : 20)
        }
        .frame(maxWidth: .infinity)
    }
}


