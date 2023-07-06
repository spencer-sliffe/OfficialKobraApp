//
//  NotificationViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 7/5/23.
//

import Foundation
import Combine
import FirebaseAuth

class NotificationViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var isLoading: Bool = true
    private let notiManager = FSNotificationManager.shared
    
    init() {
        fetchNotifications()
    }
    
    func fetchNotifications() {
        isLoading = true
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            isLoading = false
            return
        }
        notiManager.fetchNotifications(accountId: user.uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let notifications):
                    self?.notifications = notifications
                case .failure(let error):
                    print("error fetching notifications: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }
    
    func updateNotificationAsSeen(notificationId: UUID) {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        notiManager.updateNotificationAsSeen(accountId: user.uid, notificationId: notificationId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.notifications.first(where: { $0.id == notificationId })?.seen = true
                case .failure(let error):
                    print("Error updating notification as seen: \(error.localizedDescription)")
                }
            }
        }
    }
}

