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
    @EnvironmentObject private var settingsViewModel: SettingsViewModel


    @ViewBuilder
    private func getView(for index: Int) -> some View {
        switch index {
        case 0:
            SettingsView()
        case 1:
            AccountView(authViewModel: authViewModel)
        case 2:
            KobraView()
        case 3:
            InboxView(viewModel: InboxViewModel())
        case 4:
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
                            Button(action: {
                                withAnimation { selectedTab = 0 }
                            }) {
                                Image(systemName: "gear")
                            }
                            .frame(maxWidth: .infinity)
                            Button(action: {
                                withAnimation { selectedTab = 1 }
                            }) {
                                Image(systemName: "person")
                            }
                            .frame(maxWidth: .infinity)
                            Button(action: {
                                withAnimation { selectedTab = 2 }
                            }) {
                                Image(systemName: "house")
                            }
                            .frame(maxWidth: .infinity)
                            Button(action: {
                                withAnimation { selectedTab = 3 }
                            }) {
                                Image(systemName: "envelope")
                            }
                            .frame(maxWidth: .infinity)
                            Button(action: {
                                withAnimation { selectedTab = 4 }
                            }) {
                                Image(systemName: "shippingbox")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom, 10)
                    }
                    .navigationBarHidden(true)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            gradientOptions[settingsViewModel.selectedGradientIndex].0,
                            gradientOptions[settingsViewModel.selectedGradientIndex].1
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
