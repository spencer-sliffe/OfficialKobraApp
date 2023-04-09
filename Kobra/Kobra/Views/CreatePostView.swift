//
//  CreatePostView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/1/23.
//

import SwiftUI
import FirebaseAuth
import SwiftUI

struct CreatePostView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @State private var postType = "advertisement"
    @State private var title = ""
    @State private var content = ""
    @State private var stepperPrice: Double = 0
    // Additional state variables for market posts
    @State private var marketPostType = "hardware"
    @State private var hardwareCondition = Hardware.HardwareCondition.used.rawValue
    @State private var category = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
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
                            if postType != "market" {
                                CustomTextField(text: $category, placeholder: "Category")
                            }
                            // Conditional view for market posts
                            if postType == "market" {
                                marketPostContent()
                            }
                        }
                        .padding()
                    }
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                    }
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Text("Select Image")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
                        ImagePicker(image: $selectedImage)
                    }
                    Spacer()
                    Button(action: {
                        guard let userEmail = Auth.auth().currentUser?.email else {
                            print("Error: User not logged in or email not found")
                            return
                        }

                        let username = userEmail.components(separatedBy: "@")[0]
                        let id = UUID()
                        let postType: Post.PostType

                        switch self.postType {
                        case "advertisement":
                            let advertisementPost = AdvertisementPost(poster: username, title: title, content: content, category: category)
                            postType = .advertisement(advertisementPost)
                        case "help":
                            let helpPost = HelpPost(poster: username, question: title, details: content, category: category)
                            postType = .help(helpPost)
                        case "news":
                            let newsPost = NewsPost(poster: username, headline: title, article: content, category: category)
                            postType = .news(newsPost)
                        case "market":
                            let marketPostType: MarketPost.MarketPostType
                            switch self.marketPostType {
                            case "hardware":
                                let hardware = Hardware(name: title, condition: Hardware.HardwareCondition(rawValue: hardwareCondition)!, description: content)
                                marketPostType = .hardware(hardware)
                            case "software":
                                let software = Software(name: title, description: content)
                                marketPostType = .software(software)
                            case "service":
                                let service = Service(name: title, description: content)
                                marketPostType = .service(service)
                            case "other":
                                let other = Other(title: title, description: content)
                                marketPostType = .other(other)
                            default:
                                fatalError("Unknown market post type")
                            }
                            let marketPost = MarketPost(vendor: username, type: marketPostType, price: stepperPrice, category: category)
                            postType = .market(marketPost)
                        default:
                            fatalError("Unknown post type")
                        }

                        let timestamp = Date()
                        let post = Post(id: id, type: postType, likes: 0, timestamp: timestamp, imageURL: nil)

                        if let image = selectedImage {
                            kobraViewModel.uploadImage(image, postId: id.uuidString) { result in
                                switch result {
                                case .success(let imageURL):
                                    var updatedPost = post
                                    updatedPost.imageURL = imageURL
                                    kobraViewModel.addPost(updatedPost) { _ in }
                                case .failure(let error):
                                    print("Error uploading image: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            kobraViewModel.addPost(post) { _ in }
                        }

                        presentationMode.wrappedValue.dismiss()
                    }) {
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
    
    private func loadImage() {
        isImagePickerPresented = false
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
                CustomTextField(text: $category, placeholder: "Category")
                VStack(alignment: .leading) {
                    Stepper(value: $stepperPrice, in: 0...Double.infinity, step: 1.0) {
                        Text("Price: $\(stepperPrice, specifier: "%.2f")")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        
       
    }

