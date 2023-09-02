//
//  FeedType.swift
//  Kobra
//
//  Created by Spencer SLiffe on 8/2/23.
//

import Foundation

public enum FeedType: String, CaseIterable, Identifiable {
    case advertisement = "Advertisement"
    case help = "Help"
    case news = "News"
    case market = "Market"
    case bug = "Bug"
    case meme = "Meme"
    public var id: String { self.rawValue }
}