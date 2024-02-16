//
//  PackageWithImage.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/7/23.
//

import SwiftUI
import Firebase

struct PackageWithImage {
    var id: UUID
    var medal: String
    var image: UIImage?
    var price: Double
    
    init(id: UUID = UUID(), medal: String, price: Double) {
        self.id = id
        self.medal = medal
        self.price = price
    }
}
extension PackageWithImage: Identifiable {}

extension PackageWithImage: Equatable {
    static func ==(lhs: PackageWithImage, rhs: PackageWithImage) -> Bool {
        return lhs.id == rhs.id
    }
}
