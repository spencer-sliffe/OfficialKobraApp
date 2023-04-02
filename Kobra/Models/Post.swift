//
//  Post.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/31/23.
//
import Foundation

struct Post: Identifiable {
    enum PostType {
        case advertisement(AdvertisementPost)
        case help(HelpPost)
        case news(NewsPost)
        case market(MarketPost)
    }
    
    var id = UUID()
    var type: PostType
    var likes: Int = 0 // Added likes property with default value of 0
}

struct AdvertisementPost {
    var poster: String
    var title: String
    var content: String
}

struct HelpPost {
    var poster: String
    var question: String
    var details: String
}

struct NewsPost {
    var poster: String
    var headline: String
    var article: String
}

struct MarketPost {
    enum MarketPostType {
        case hardware(Hardware)
        case software(Software)
        case service(Service)
        case other(Other)
    }
    
    var vendor: String // Assuming the 'vendor' property is the same as 'poster' for MarketPosts
    var type: MarketPostType
}

struct Hardware {
    enum HardwareCondition: String {
        case new
        case used
    }
    
    var name: String
    var condition: HardwareCondition
    var price: Double
}


struct Software {
    var name: String
    var description: String
    var price: Double
    var category: String
}

struct Service {
    var name: String
    var description: String
    var price: Double
    var category: String
}

struct Other {
    var title: String
    var description: String
}
