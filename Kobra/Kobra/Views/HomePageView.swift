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

    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    @EnvironmentObject private var notificationViewModel: NotificationViewModel
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var discoverViewModel: DiscoverViewModel
    @EnvironmentObject private var inboxViewModel: InboxViewModel

    var body: some View {
        NavigationView {
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
                .onChange(of: selectedTab) { newValue in
                    if selectedTab == 4 {
                        notificationViewModel.markAllAsSeen()
                    }
                }
                CustomTabView(selectedTab: $selectedTab)
                    .environmentObject(notificationViewModel)
                    .environmentObject(inboxViewModel)
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

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func getView(for index: Int) -> some View {
        generateView(for: index)
    }

    private func generateView(for index: Int) -> AnyView {
        switch index {
        case 0:
            return AnyView(SettingsView()
                .environmentObject(authViewModel))
        case 1:
            return AnyView(AccountView()
                .environmentObject(homePageViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(kobraViewModel)
                .environmentObject(accountViewModel))
        case 2:
            return AnyView(DiscoverView()
                .environmentObject(homePageViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(discoverViewModel)
                .environmentObject(kobraViewModel)
                .onTapGesture {
                    hideKeyboard()
                })
        case 3:
            return AnyView(KobraView()
                .environmentObject(kobraViewModel)
                .environmentObject(homePageViewModel)
                .environmentObject(settingsViewModel))
        case 4:
            return AnyView(NotificationView()
                .onAppear(){
                    notificationViewModel.markAllAsSeen()
                }
                .environmentObject(kobraViewModel)
                .environmentObject(homePageViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(notificationViewModel))
            
        case 5:
            return AnyView(InboxView()
                .environmentObject(homePageViewModel)
                .environmentObject(inboxViewModel)
                .environmentObject(settingsViewModel))
        case 6:
            return AnyView(FoodView()
                .environmentObject(homePageViewModel))
        default:
            return AnyView(EmptyView())
        }
    }
}

struct CustomTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject private var notificationViewModel: NotificationViewModel
    @EnvironmentObject private var inboxViewModel: InboxViewModel
    
    private func getIcon(for index: Int) -> String {
        switch index {
        case 0:
            return "gear"
        case 1:
            return "person"
        case 2:
            return "doc.text.magnifyingglass"
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
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7) { index in
                self.createTabButton(icon: self.getIcon(for: index), tabIndex: index)
            }
        }
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func createTabButton(icon: String, tabIndex: Int) -> some View {
        Button(action: {
            selectedTab = tabIndex
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
                if tabIndex == 5 && inboxViewModel.unreadMessagesCount > 0 {
                    Text("\(inboxViewModel.unreadMessagesCount)")
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
