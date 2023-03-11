//
//  Package.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/1/23.
//

import SwiftUI
import Firebase

struct Package {
    var id: String
    var name: String
    var price: Double
    
    init(id: String, name: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
    }
}

extension Package: Identifiable {}

extension Package: Equatable {
    static func ==(lhs: Package, rhs: Package) -> Bool {
        return lhs.id == rhs.id
    }
}
