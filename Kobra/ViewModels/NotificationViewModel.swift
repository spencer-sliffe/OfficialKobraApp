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
    
    private func updateNotificationsAsSeen() {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        notiManager.updateNotificationsAsSeen(accountId: user.uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.notifications.forEach { $0.seen = true }
                case .failure(let error):
                    print("Error updating notifications as seen: \(error.localizedDescription)")
                }
            }
        }
    }
}
