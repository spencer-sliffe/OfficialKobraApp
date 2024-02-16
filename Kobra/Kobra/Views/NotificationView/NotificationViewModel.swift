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
    @Published var post: Post?
    private let postManager = FSPostManager.shared
    
    var unseenNotificationsCount: Int {
        notifications.filter { $0.seen == false }.count
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
    
    func fetchPostById(postId: String) {
        postManager.fetchPostById(postId: postId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    self?.post = post
                case .failure(let error):
                    print("Error fetching post: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func markAllAsSeen() {
        for notification in notifications where !notification.seen {
            updateNotificationAsSeen(notificationId: notification.id)
        }
    }
    
    func resetData() {
        notifications = []
        isLoading = true
        post = nil
    }
}

