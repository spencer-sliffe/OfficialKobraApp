//  NotificationView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/5/23.
//

import Foundation
import SwiftUI

struct NotificationView: View {
    @ObservedObject var viewModel = NotificationViewModel()
    @EnvironmentObject var homePageViewModel: HomePageViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Unseen Notifications: \(viewModel.unseenNotificationsCount)")
                .padding(.horizontal)
                .foregroundColor(.white)
            Divider()
                .frame(height: 1)
                .background(.gray)
                .padding(.bottom, 4)
            if viewModel.isLoading {
               Spacer()
               ProgressView()
               Spacer()
            } else {
                ScrollView {
                    ForEach(viewModel.notifications.sorted(by: { $0.timestamp > $1.timestamp })) { notification in
                        NotificationCell(notification: notification)
                            .environmentObject(homePageViewModel)
                            .environmentObject(settingsViewModel)
                    }
                }
                .refreshable {
                    viewModel.fetchNotifications()
                }
            }
        }
        .onDisappear {
            viewModel.markAllAsSeen()
        }
        .edgesIgnoringSafeArea(.all)
    }
}
