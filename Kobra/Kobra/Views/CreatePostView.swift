//
//  CreatePostView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/1/23.
//
import SwiftUI
import FirebaseAuth
import AVKit

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
    @State private var username: String = ""
    @State private var selectedVideoURL: URL?
    @State private var isMediaPickerPresented = false
    
    var isPostDataValid: Bool {
        if title.isEmpty || title.count > 60 || content.isEmpty || (postType != "Meme" && category.isEmpty) {
            return false
        }
        if postType == "Market" && (stepperPrice == 0 || (marketPostType == "Hardware" && hardwareCondition.isEmpty)) {
            return false
        }
        return true
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        DropDownMenu(
                            isExpanded: $postTypeExpanded,
                            options: ["Advertisement", "Help", "News", "Market", "Bug", "Meme"],
                            selection: $postType,
                            onOptionSelected: { _ in }
                        )
                        .frame(maxWidth: .infinity)
                        
                        CustomTextField(text: $title, placeholder: NSLocalizedString("Title", comment: ""), characterLimit: 40)
                            .onChange(of: title) { newValue in
                                // Truncate the title if it exceeds the character limit
                                if newValue.count > 40 {
                                    title = String(newValue.prefix(40))
                                }
                            }
                        
                        CustomTextField(text: $content, placeholder: NSLocalizedString("Content", comment: ""), characterLimit: 300)
                            .onChange(of: content) { newValue in
                                // Truncate the title if it exceeds the character limit
                                if newValue.count > 300 {
                                    content = String(newValue.prefix(300))
                                }
                            }
                        
                        if postType != "Market" && postType != "Meme" {
                            CustomTextField(text: $category, placeholder: NSLocalizedString("Category", comment: ""), characterLimit: 20)
                                .onChange(of: category) { newValue in
                                    // Truncate the title if it exceeds the character limit
                                    if newValue.count > 20 {
                                        category = String(newValue.prefix(20))
                                    }
                                }
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
                } else if let videoURL = selectedVideoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(maxWidth: 200, maxHeight: 200)
                        .shadow(radius: 10)
                }
                
                Button(action: {
                    isMediaPickerPresented = true
                }) {
                    Text(NSLocalizedString("Select Image/Video", comment: ""))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                }
                .sheet(isPresented: $isMediaPickerPresented, onDismiss: loadMedia) {
                    ImageVideoPicker(image: $selectedImage, video: $selectedVideoURL)
                }
                
                Spacer()
                if kobraViewModel.isUploadInProgress {
                    VStack {
                        ProgressView(value: kobraViewModel.uploadProgress, total: 100)
                            .frame(height: 20)
                            .padding()
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        Text("\(Int(kobraViewModel.uploadProgress))%")
                            .font(.title)
                            .bold()
                            .padding()
                    }
                }
                
                Button(action: {
                    addPostAction()
                })  {
                    Text(NSLocalizedString("Post", comment: ""))
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding([.top, .bottom])
                }
                .disabled(!isPostDataValid) // Disable the button if post data is not valid
                .opacity(isPostDataValid ? 1 : 0.5) // Reduce opacity if post data is not valid
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
        .navigationBarTitle(NSLocalizedString("Create Post", comment: ""), displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text(NSLocalizedString("Cancel", comment: ""))
                .foregroundColor(.white)
        })
    }
    
    func loadMedia() {
        if let _ = selectedImage {
            selectedVideoURL = nil
        } else if let _ = selectedVideoURL {
            selectedImage = nil
        }
    }
    
    func addPostAction() {
        kobraViewModel.uploadProgress = 0.0
        kobraViewModel.fetchUsername { result in
            switch result {
            case .success(let fetchedUsername):
                self.username = fetchedUsername
                
                guard let posterId = Auth.auth().currentUser?.uid else {
                    print("Error: User not logged in or uid not found")
                    return
                }
                
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
                case "Bug":
                    let bugPost = AppBugPost(poster: username, title: title, content: content, category: category)
                    postType = .bug(bugPost)
                case "Meme":
                    let memePost = MemePost(poster: username, title: title, content: content)
                    postType = .meme(memePost)
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
                let post = Post(id: id, type: postType, likes: 0, timestamp: timestamp, imageURL: nil, videoURL: nil, likingUsers: [""], comments: [], posterId: posterId)
                
                if let image = selectedImage {
                    kobraViewModel.uploadImage(image, postId: id.uuidString) { result in
                        switch result {
                        case .success(let imageURL):
                            let updatedPost = post
                            updatedPost.imageURL = imageURL
                            kobraViewModel.addPost(updatedPost) { _ in
                                presentationMode.wrappedValue.dismiss()
                            }
                        case .failure(let error):
                            print("Error uploading image: \(error.localizedDescription)")
                        }
                    }
                } else if let videoURL = selectedVideoURL {
                    kobraViewModel.uploadVideo(videoURL, postId: id.uuidString) { result in
                        switch result {
                        case .success(let videoURLString):
                            let updatedPost = post
                            updatedPost.videoURL = videoURLString
                            kobraViewModel.addPost(updatedPost) { _ in
                                presentationMode.wrappedValue.dismiss()
                            }
                            
                        case .failure(let error):
                            print("Error uploading video: \(error.localizedDescription)")
                        }
                    }
                } else {
                    kobraViewModel.addPost(post) { _ in
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    @ViewBuilder
    private func marketPostContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(NSLocalizedString("Market Post Type", comment: ""))
                .foregroundColor(.white)
            DropDownMenu(
                isExpanded: $marketPostTypeExpanded,
                options: ["Hardware", "Software", "Service", "Other"],
                selection: $marketPostType,
                onOptionSelected: { _ in }
            )
            .frame(maxWidth: .infinity)
            
            if marketPostType == "Hardware" {
                Text(NSLocalizedString("Condition", comment: ""))
                    .foregroundColor(.white)
                DropDownMenu(
                    isExpanded: $hardwareConditionExpanded,
                    options: [Hardware.HardwareCondition.new.rawValue, Hardware.HardwareCondition.used.rawValue],
                    selection: $hardwareCondition,
                    onOptionSelected: { _ in }
                )
                .frame(maxWidth: .infinity)
                
            }
            CustomTextField(text: $category, placeholder: NSLocalizedString("Category", comment: ""), characterLimit: 20)
                .onChange(of: category) { newValue in
                    // Truncate the title if it exceeds the character limit
                    if newValue.count > 20 {
                        category = String(newValue.prefix(20 ))
                    }
                }
            VStack(alignment: .leading) {
                Stepper(value: $stepperPrice, in: 0...Double.infinity, step: 1.0) {
                    Text(String(format: NSLocalizedString("Price: $%.2f", comment: ""), stepperPrice))
                        .foregroundColor(.white)
                }
            }
        }
    }
}
