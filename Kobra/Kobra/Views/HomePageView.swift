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
    @StateObject var notificationViewModel = NotificationViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if !authViewModel.isAuthenticated {
                    AuthenticationView(authViewModel: authViewModel)
                } else {
                    VStack {
                        TabView(selection: $selectedTab) {
                            ForEach(0..<7) { index in
                                self.getView(for: index)
                                    .tag(index)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))

                        HStack(spacing: 0) {
                            ForEach(0..<7) { index in
                                self.createTabButton(icon: self.getIcon(for: index), tabIndex: index)
                            }
                        }
                        .padding(.bottom, 16)
                        .padding(.horizontal, 5)
                    }
                    .navigationBarHidden(true)
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
        }
    }

    private func getIcon(for index: Int) -> String {
        switch index {
        case 0:
            return "gear"
        case 1:
            return "person"
        case 2:
            return "magnifyingglass"
        case 3:
            return "house"
        case 4:
            return "bell"
        case 5:
            return "envelope"
        case 6:
            return "leaf"
        default:
            return "questionmark"
        }
    }
    
    @ViewBuilder
    private func getView(for index: Int) -> some View {
        switch index {
        case 0:
            SettingsView(authViewModel: authViewModel)
        case 1:
            AccountView()
        case 2:
            DiscoverView()
        case 3:
            KobraView()
        case 4:
            NotificationView()
        case 5:
            EmptyView()
        case 6:
            FoodView()
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func createTabButton(icon: String, tabIndex: Int) -> some View {
        Button(action: {
            withAnimation { selectedTab = tabIndex }
        }) {
            ZStack {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: selectedTab == tabIndex ? 28 : 24, height: selectedTab == tabIndex ? 26 : 22)
                    .foregroundColor(selectedTab == tabIndex ? .yellow : .white)
                
                // add a badge for notifications
                if tabIndex == 4 && notificationViewModel.unseenNotificationsCount > 0 {
                    Text("\(notificationViewModel.unseenNotificationsCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(2)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
