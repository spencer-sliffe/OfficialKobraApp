//
//  Post.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/31/23.
//
import Foundation

class Post: Identifiable, ObservableObject {
    enum PostType {
        case advertisement(AdvertisementPost)
        case help(HelpPost)
        case news(NewsPost)
        case market(MarketPost)
        case bug(AppBugPost)
        case meme(MemePost)
        
        var feedType: FeedType {
            switch self {
            case .advertisement(_):
                return .advertisement
            case .help(_):
                return .help
            case .news(_):
                return .news
            case .market(_):
                return .market
            case .bug(_):
                return .bug
            case .meme(_):
                return .meme
            }
        }
    }
    
    var id = UUID()
    var type: PostType
    var likes: Int = 0
    var timestamp: Date
    var imageURL: String?
    var videoURL: String?
    var dislikes: Int = 0
    @Published var likingUsers: [String]
    @Published var dislikingUsers: [String]
    var comments: [Comment]
    var posterId: String // new property
    var numComments: Int = 0
    
    init(id: UUID = UUID(), type: PostType, likes: Int = 0, timestamp: Date, imageURL: String? = nil, videoURL: String? = nil, likingUsers: [String] = [], dislikingUsers: [String] = [], comments: [Comment], dislikes: Int = 0, posterId: String, numComments: Int = 0) {
        self.id = id
        self.type = type
        self.likes = likes
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.likingUsers = likingUsers
        self.dislikingUsers = dislikingUsers
        self.comments = comments
        self.dislikes = dislikes
        self.posterId = posterId // new property
        self.numComments = numComments
    }
}

struct MemePost {
    var poster: String
    var title: String
    var content: String
}

struct AppBugPost {
    var poster: String
    var title: String
    var content: String
    var category: String
}

struct AdvertisementPost {
    var poster: String
    var title: String
    var content: String
    var category: String
}

struct HelpPost {
    var poster: String
    var question: String
    var details: String
    var category: String
}

struct NewsPost {
    var poster: String
    var headline: String
    var article: String
    var category: String
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
    var price: Double
    var category: String
}

struct Hardware {
    enum HardwareCondition: String {
        case new
        case used
    }
    var name: String
    var condition: HardwareCondition
    var description: String
}

struct Software {
    var name: String
    var description: String
}

struct Service {
    var name: String
    var description: String
}

struct Other {
    var title: String
    var description: String
}
