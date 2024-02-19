//
//  CustomTabView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/5/24.
//

import Foundation
import SwiftUI

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
                
                if tabIndex == 4 && notificationViewModel.unseenNotificationsCount > 0 {            // add a badge for notifications
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
