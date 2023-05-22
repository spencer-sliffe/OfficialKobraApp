//
//  Food.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/21/23.
//

import Foundation

struct Food: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var ingredients: [String]
    var steps: [String]
    var image: String
    var preparationTime: String
}
