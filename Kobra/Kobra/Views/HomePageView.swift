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
    @State private var previousTab = 3
    @ObservedObject var authViewModel = AuthenticationViewModel()
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @StateObject var kobraViewModel = KobraViewModel()
    @ObservedObject var notificationViewModel = NotificationViewModel()
    @State private var viewsCache: [Int: AnyView] = [:]
    @StateObject private var homePageViewModel = HomePageViewModel()
    
    var body: some View {
        NavigationView {
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
                    .onChange(of: selectedTab) { newValue in
                        if previousTab == 4 {
                            notificationViewModel.markAllAsSeen()
                        }
                        previousTab = newValue
                    }
                    
                    CustomTabView(selectedTab: $selectedTab, notificationViewModel: notificationViewModel)
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
                .onTapGesture {
                    // dismiss keyboard
                    if selectedTab == 2 {
                        hideKeyboard()
                    }
                }
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
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
    
    private func getView(for index: Int) -> some View {
         viewsCache[index] ?? createAndCacheView(for: index)
     }

     private func createAndCacheView(for index: Int) -> AnyView {
         let newView = generateView(for: index)
         viewsCache[index] = newView
         return newView
     }

     private func generateView(for index: Int) -> AnyView {
         switch index {
         case 0:
             return AnyView(SettingsView(authViewModel: authViewModel))
         case 1:
             return AnyView(AccountView()
                .environmentObject(homePageViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(kobraViewModel))
         case 2:
             return AnyView(DiscoverView()
                .environmentObject(homePageViewModel)
                .environmentObject(settingsViewModel))
         case 3:
             return AnyView(KobraView()
                .environmentObject(kobraViewModel)
                .environmentObject(homePageViewModel)
                .environmentObject(settingsViewModel)
                .onAppear(){
                 kobraViewModel.fetchPosts()
             })
         case 4:
             return AnyView(NotificationView()
                .environmentObject(kobraViewModel)
                .environmentObject(homePageViewModel)
                .environmentObject(settingsViewModel))
         case 5:
             return AnyView(InboxView()
                .environmentObject(homePageViewModel))
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
    @ObservedObject var notificationViewModel: NotificationViewModel
    
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
            }
        }
        .frame(maxWidth: .infinity)
    }
}
