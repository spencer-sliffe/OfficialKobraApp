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
}

struct AdvertisementPost {
    // Add properties for AdvertisementPost
}

struct HelpPost {
    // Add properties for HelpPost
}

struct NewsPost {
    // Add properties for NewsPost
}

struct MarketPost {
    enum MarketPostType {
        case hardware(Hardware)
        case software(Software)
        case service(Service)
        case other(Other)
    }
    
    var type: MarketPostType
}

struct Hardware {
    enum HardwareCondition {
        case new
        case used
    }
    
    var condition: HardwareCondition
    // Add other properties for Hardware if needed
}

struct Service {

}
struct Software {
    // Add properties for Software
}

struct Other {
    // Add properties for Other
}
