//
//  Comment.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/13/23.
//

import Foundation

struct Comment: Codable, Identifiable {
    var id = UUID()
    var text: String
    var commenter: String
    var timestamp: Date
}
