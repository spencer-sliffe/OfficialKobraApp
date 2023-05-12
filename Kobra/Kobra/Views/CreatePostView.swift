//
//  CreatePostView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/1/23
//
import SwiftUI
import FirebaseAuth

struct CreatePostView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @State private var postType = "Advertisement"
    @State private var title = ""
    @State private var content = ""
    @State private var stepperPrice: Double = 0
    @State private var marketPostType = "Hardware"
    @State private var hardwareCondition = Hardware.HardwareCondition.used.rawValue
    @State private var category = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var postTypeExpanded = false
    @State private var marketPostTypeExpanded = false
    @State private var hardwareConditionExpanded = false
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Post Type")
                            .foregroundColor(.white)
                        DropDownMenu(
                            isExpanded: $postTypeExpanded,
                            options: ["Advertisement", "Help", "News", "Market"],
                            selection: $postType,
                            onOptionSelected: { _ in }
                        )
                        .frame(maxWidth: .infinity)
                        
                        CustomTextField(text: $title, placeholder: "Title")
                        CustomTextField(text: $content, placeholder: "Content")
                        
                        if postType != "Market" {
                            CustomTextField(text: $category, placeholder: "Category")
                        }
                        if postType == "Market" {
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
                        .shadow(radius: 10)
                }
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Text("Select Image")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
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
                    case "Advertisement":
                        let advertisementPost = AdvertisementPost(poster: username, title: title, content: content, category: category)
                        postType = .advertisement(advertisementPost)
                    case "Help":
                        let helpPost = HelpPost(poster: username, question: title, details: content, category: category)
                        postType = .help(helpPost)
                    case "News":
                        let newsPost = NewsPost(poster: username, headline: title, article: content, category: category)
                        postType = .news(newsPost)
                    case "Market":
                        let marketPostType: MarketPost.MarketPostType
                        switch self.marketPostType {
                        case "Hardware":
                            let hardware = Hardware(name: title, condition: Hardware.HardwareCondition(rawValue: hardwareCondition)!, description: content)
                            marketPostType = .hardware(hardware)
                        case "Software":
                            let software = Software(name: title, description: content)
                            marketPostType = .software(software)
                        case "Service":
                            let service = Service(name: title, description: content)
                            marketPostType = .service(service)
                        case "Other":
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
                    let post = Post(id: id, type: postType, likes: 0, timestamp: timestamp, imageURL: nil, likingUsers: [""], comments: [])
                    
                    if let image = selectedImage {
                        kobraViewModel.uploadImage(image, postId: id.uuidString) { result in
                            switch result {
                            case .success(let imageURL):
                                let updatedPost = post
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
                })  {
                    Text("Post")
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            gradientOptions[settingsViewModel.gradientIndex].0,
                            gradientOptions[settingsViewModel.gradientIndex].1
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .navigationBarTitle("Create Post", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel")
                .foregroundColor(.white)
        })
    }
    
    private func loadImage() {
        isImagePickerPresented = false
    }
    
    @ViewBuilder
    private func marketPostContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Market Post Type")
                .foregroundColor(.white)
            DropDownMenu(
                isExpanded: $marketPostTypeExpanded,
                options: ["Hardware", "Software", "Service", "Other"],
                selection: $marketPostType,
                onOptionSelected: { _ in }
            )
            .frame(maxWidth: .infinity)
            
            if marketPostType == "Hardware" {
                Text("Condition")
                    .foregroundColor(.white)
                DropDownMenu(
                    isExpanded: $hardwareConditionExpanded,
                    options: [Hardware.HardwareCondition.new.rawValue, Hardware.HardwareCondition.used.rawValue],
                    selection: $hardwareCondition,
                    onOptionSelected: { _ in }
                )
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

