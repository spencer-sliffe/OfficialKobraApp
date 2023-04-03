//
//  CreatePostView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/1/23.
//

import SwiftUI
import FirebaseAuth

struct CreatePostView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @State private var postType = ""
    @State private var title = ""
    @State private var content = ""
    
    // Additional state variables for market posts
    @State private var marketPostType = ""
    @State private var price: Double? = nil
    @State private var hardwareCondition = Hardware.HardwareCondition.used.rawValue
    @State private var category = ""

    var body: some View {
        VStack{
            Form {
            Picker("Post Type", selection: $postType) {
                Text("Advertisement").tag("advertisement")
                Text("Help").tag("help")
                Text("News").tag("news")
                Text("Market").tag("market")
            }
            
            TextField("Title", text: $title)
            TextField("Content", text: $content)
            
            // Conditional view for market posts
            if postType == "market" {
                Picker("Market Post Type", selection: $marketPostType) {
                    Text("Hardware").tag("hardware")
                    Text("Software").tag("software")
                    Text("Service").tag("service")
                    Text("Other").tag("other")
                }
                
                if marketPostType == "hardware" {
                    Picker("Condition", selection: $hardwareCondition) {
                        Text("New").tag(Hardware.HardwareCondition.new.rawValue)
                        Text("Used").tag(Hardware.HardwareCondition.used.rawValue)
                    }
                }
                
                if marketPostType == "software" || marketPostType == "service" {
                    TextField("Category", text: $category)
                }
                
                TextField("Price", value: $price, formatter: NumberFormatter())
            }
        }
        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
                LinearGradient(
                    gradient: Gradient(colors: [.black, .blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
        
    

    private func savePost() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: User not logged in or email not found")
            return
        }
        
        let username = userEmail.components(separatedBy: "@")[0]
        
        let id = UUID()
        let postType: Post.PostType

        switch self.postType {
        case "advertisement":
            let advertisementPost = AdvertisementPost(poster: username, title: title, content: content)
            postType = .advertisement(advertisementPost)
        case "help":
            let helpPost = HelpPost(poster: username, question: title, details: content)
            postType = .help(helpPost)
        case "news":
            let newsPost = NewsPost(poster: username, headline: title, article: content)
            postType = .news(newsPost)
        case "market":
            let marketPostType: MarketPost.MarketPostType = .other(Other(title: title, description: content))
            let marketPost = MarketPost(vendor: username, type: marketPostType)
            postType = .market(marketPost)
        default:
            fatalError("Unknown post type")
        }

        let post = Post(id: id, type: postType, likes: 0)
        kobraViewModel.addPost(post)
    }
}
