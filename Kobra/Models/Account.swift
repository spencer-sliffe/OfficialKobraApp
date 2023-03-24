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
    var subscription: Bool
    var package: Package?
    var profilePicture: URL?

    init(id: String, email: String, subscription: Bool, packageData: [String: Any]?, profilePicture: String?) {
        self.id = id
        self.email = email
        self.subscription = subscription
        self.package = packageData.flatMap {
            guard
                let id = $0["id"] as? String,
                let name = $0["name"] as? String,
                let price = $0["price"] as? Double
            else {
                return nil
            }
            return Package(id: id, name: name, price: price)
        }
        self.profilePicture = profilePicture.flatMap { URL(string: $0) }
    }
}
