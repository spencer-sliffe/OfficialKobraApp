//
//  Account.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/7/23.
//
import Foundation

struct Account {
    var id: String
    var email: String
    var username: String
    var subscription: Bool
    var package: String
    var profilePicture: URL?
    var followers: [String]  // Now holds emails
    var following: [String]  // Now holds emails

    init(id: String, email: String, username: String, subscription: Bool, package: String, profilePicture: String?, followers: [String] = [], following: [String] = []) {
        self.id = id
        self.email = email
        self.username = username
        self.subscription = subscription
        self.package = package
        self.profilePicture = profilePicture.flatMap { URL(string: $0) }
        self.followers = followers
        self.following = following
    }
}
