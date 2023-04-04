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
    @State private var stepperPrice: Double = 0
    
    // Additional state variables for market posts
    @State private var marketPostType = "hardware"
    @State private var price: Double = 0.0
    @State private var hardwareCondition = Hardware.HardwareCondition.used.rawValue
    @State private var category = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.black, .blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {

                            KobraPicker(title: "Post Type", selection: $postType) {
                                Text("Advertisement").tag("advertisement")
                                Text("Help").tag("help")
                                Text("News").tag("news")
                                Text("Market").tag("market")
                            }
                            .frame(maxWidth: .infinity)

                            CustomTextField(text: $title, placeholder: "Title")
                            CustomTextField(text: $content, placeholder: "Content")
                            CustomTextField(text: $category, placeholder: "Category")


                            // Conditional view for market posts
                            if postType == "market" {
                                marketPostContent()
                            }
                        }
                        .padding()
                    }
                    Spacer()
                    Button(action: savePost) {
                        Text("Post")
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
        }
    }
    
    @ViewBuilder
    private func marketPostContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {

            KobraPicker(title: "Market Post Type", selection: $marketPostType) {
                Text("Hardware").tag("hardware")
                Text("Software").tag("software")
                Text("Service").tag("service")
                Text("Other").tag("other")
            }
            .frame(maxWidth: .infinity)

            if marketPostType == "hardware" {
                KobraPicker(title: "Condition", selection: $hardwareCondition) {
                    Text("New").tag(Hardware.HardwareCondition.new.rawValue)
                    Text("Used").tag(Hardware.HardwareCondition.used.rawValue)
                }
                .frame(maxWidth: .infinity)
            }

            if marketPostType == "software" || marketPostType == "service" {
                CustomTextField(text: $category, placeholder: "Category")
            }

            VStack(alignment: .leading) {
                       Stepper(value: $stepperPrice, in: 0...Double.infinity, step: 1.0) {
                           Text("Price: $\(stepperPrice, specifier: "%.2f")")
                               .foregroundColor(.white)
                       }
                       .onChange(of: stepperPrice) { value in
                           price = value
                       }
                   }
        }
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
