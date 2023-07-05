//
//  NotificationView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/5/23.
//

import Foundation
import SwiftUI

struct NotificationView: View {
    @ObservedObject var viewModel = NotificationViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
               Spacer()
              ProgressView()
               Spacer()
           } else {
                ScrollView {
                        ForEach(viewModel.notifications.sorted(by: { $0.timestamp > $1.timestamp })) {
                            notification in
                            NotificationCell(notification: notification)
                        }
                    
                }
                .refreshable{
                    viewModel.fetchNotifications()
                }
            }
        }
    }
}

