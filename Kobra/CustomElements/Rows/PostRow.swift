//  PostRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/1/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import AVKit
import AVFoundation

struct PostRow: View {
    @ObservedObject var post: Post
    @State private var isLiked = false
    @State private var likes = 0
    @State private var isDisliked = false
    @State private var dislikes = 0
    @State private var showingComments = false
    @State private var showingFullImage = false // new state for full screen image
    let currentUserId: String = Auth.auth().currentUser?.uid ?? ""
    @State private var showingDeleteConfirmation = false
    @State private var profilePictureURL: URL?
    @State private var playerStatus: AVPlayer.Status = .unknown
    @State private var shouldPlayVideo = false
    @Binding var selectedFeed: FeedType
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @State private var isInView = false
    
    init(post: Post, selectedFeed: Binding<FeedType>) {
        self.post = post
        self._selectedFeed = selectedFeed
        _likes = State(initialValue: post.likes)
        _dislikes = State(initialValue: post.dislikes)
        _isLiked = State(initialValue: post.likingUsers.contains(currentUserId))
        _isDisliked = State(initialValue: post.dislikingUsers.contains(currentUserId))
    }
    
    var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                NavigationLink(destination: AccountProfileView(accountId: post.posterId)
                    .environmentObject(homePageViewModel)
                    .environmentObject(kobraViewModel)
                    .environmentObject(settingsViewModel)) {
                        getPosterName()
                    }
                Spacer()
                
                if currentUserId == post.posterId {
                    Button(action: deletePost) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            Divider()
                .frame(height: 1)
                .background(.gray)
            VStack {
                switch post.type {
                case .advertisement(let advertisementPost):
                    let content = advertisementPost.content
                    PostContent(content: content,
                                imageURL: post.imageURL, videoURL: post.videoURL)
                case .help(let helpPost):
                    let content = helpPost.details
                    PostContent(content: content,
                                imageURL: post.imageURL, videoURL: post.videoURL)
                case .news(let newsPost):
                    let content = newsPost.category + " News: " + newsPost.article
                    PostContent(content: content,
                                imageURL: post.imageURL, videoURL: post.videoURL)
                case .bug(let bugPost):
                    let content = "App Bug: " + bugPost.content
                    PostContent(content: content,
                                imageURL: post.imageURL, videoURL: post.videoURL)
                case .meme(let memePost):
                    let content = memePost.content
                    PostContent(content: content,
                                imageURL: post.imageURL, videoURL: post.videoURL)
                case .market(let marketPost):
                    MarketPostContent(marketPost: marketPost, imageURL: post.imageURL, videoURL: post.videoURL)
                }
            }
            
            HStack {
                Button(action: {
                    isLiked.toggle()
                    if isLiked {
                        likes += 1
                        post.likingUsers.append(currentUserId)
                    } else {
                        likes -= 1
                        post.likingUsers.removeAll { $0 == currentUserId }
                    }
                    if isDisliked {
                        isDisliked.toggle()
                        dislikes -= 1
                        kobraViewModel.updateDislikeCount(post, dislikeCount: dislikes, userId: currentUserId, isAdding: isDisliked)
                    }
                    kobraViewModel.updateLikeCount(post, likeCount: likes, userId: currentUserId, isAdding: isLiked)
                }) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(likes)")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(5)
                            .background(Color.red.opacity(0.5))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.red, lineWidth: 1)
                            )
                    }
                }
                Button(action: {
                    isDisliked.toggle()
                    if isDisliked {
                        dislikes += 1
                        post.dislikingUsers.append(currentUserId)
                    } else {
                        dislikes -= 1
                        post.dislikingUsers.removeAll { $0 == currentUserId }
                    }
                    if isLiked {
                        isLiked.toggle()
                        likes -= 1
                        post.likingUsers.removeAll { $0 == currentUserId }
                        kobraViewModel.updateLikeCount(post, likeCount: likes, userId: currentUserId, isAdding: isLiked)
                    }
                    kobraViewModel.updateDislikeCount(post, dislikeCount: dislikes, userId: currentUserId, isAdding: isDisliked)
                }) {
                    HStack {
                        Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .foregroundColor(isDisliked ? .black : .gray)
                        Text("\(dislikes)")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(5)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
                Button(action: {
                    showingComments.toggle()
                }) {
                    HStack {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("\(post.numComments)")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(5)
                            .background(Color.blue.opacity(0.5))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.blue, lineWidth: 1)
                            )
                    }
                }
                Spacer()
                Text(post.timestamp.formatted())
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(getBackgroundColor(for: post.type))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .sheet(isPresented: $showingComments) {
            CommentView(post: post)
                .environmentObject(kobraViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(homePageViewModel)
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Post"),
                message: Text("Are you sure you want to delete this post?"),
                primaryButton: .destructive(Text("Delete")) {
                    kobraViewModel.deletePost(post)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func getBackgroundColor(for postType: Post.PostType) -> Color {
        switch postType {
        case .advertisement:
            return Color.purple.opacity(0.35)
        case .help:
            return Color.green.opacity(0.35)
        case .news:
            return Color.red.opacity(0.35)
        case .bug:
            return Color.teal.opacity(0.35)
        case .meme:
            return Color.indigo.opacity(0.35)
        case .market:
            return Color.yellow.opacity(0.35)
        }
    }
    
    func deletePost() {
        showingDeleteConfirmation = true
    }
    
    func getPosterName() -> some View {
        HStack {
            if let url = profilePictureURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.gray))
                }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(.gray))
            }
            
            switch post.type {
            case .advertisement(let advertisementPost):
                Text(advertisementPost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(advertisementPost.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .help(let helpPost):
                Text(helpPost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(helpPost.question + "?")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .news(let newsPost):
                Text(newsPost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(newsPost.headline)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .bug(let bugPost):
                Text(bugPost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(bugPost.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .meme(let memePost):
                Text(memePost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(memePost.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .market(let marketPost):
                Text(marketPost.vendor)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .onAppear {
            kobraViewModel.fetchProfilePicture(for: post) { result in
                switch result {
                case .success(let url):
                    self.profilePictureURL = url
                case .failure(let error):
                    print("Error fetching profile picture: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func canLike() -> Bool {
        return !post.likingUsers.contains(currentUserId)
    }
    
    func canDislike() -> Bool {
        return !post.dislikingUsers.contains(currentUserId)
    }
    
    func PostContent(content: String, imageURL: String?, videoURL: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            VStack(alignment:.center){
                if let imageURL = imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(5)
                                .contentShape(Rectangle())
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(5)
                                .contentShape(Rectangle())
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5, anchor: .center)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxHeight: 300)
                    .fullScreenCover(isPresented: $showingFullImage) {
                        ZStack {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .contentShape(Rectangle())
                            } placeholder: {
                                ProgressView()
                                    .accentColor(.white)
                            }
                            .ignoresSafeArea()
                            .onTapGesture {
                                showingFullImage = false
                            }
                        }
                    }
                }
                if let videoURL = videoURL, let url = URL(string: videoURL) {
                    VideoPlayerView(videoURL: url, shouldPlay: .constant((post.type.feedType == selectedFeed || selectedFeed == .all) && shouldPlayVideo && homePageViewModel.accProViewActive == false), isInView: $shouldPlayVideo)
                        .frame(height: 300)
                        .isInView { inView in
                            shouldPlayVideo = inView
                        }
                        .contentShape(Rectangle())
                }
            }
            HStack(){
                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    func MarketPostContent(marketPost: MarketPost, imageURL: String?, videoURL: String?) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            switch marketPost.type {
            case .hardware(let hardware):
                Text("Hardware: \(hardware.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(hardware.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .software(let software):
                Text("Software: \(software.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(software.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .service(let service):
                Text("Service: \(service.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(service.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .other(let other):
                Text("Other: \(other.title)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(other.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(5)
                            .contentShape(Rectangle())
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(5)
                            .contentShape(Rectangle())
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5, anchor: .center)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: 300)
                /*.fullScreenCover(isPresented: $showingFullImage) {
                 ZStack {
                 AsyncImage(url: url) { image in
                 image
                 .resizable()
                 .scaledToFit()
                 } placeholder: {
                 ProgressView()
                 }
                 .ignoresSafeArea()
                 }
                 .onTapGesture {
                 showingFullImage = false
                 }
                 }*/
            }
            if let videoURL = videoURL, let url = URL(string: videoURL) {
                VideoPlayerView(videoURL: url, shouldPlay: .constant((post.type.feedType == selectedFeed || selectedFeed == .all) && shouldPlayVideo && homePageViewModel.accProViewActive == false), isInView: $shouldPlayVideo)
                    .frame(height: 300)
                    .isInView { inView in
                        shouldPlayVideo = inView
                    }
                    .contentShape(Rectangle())
            }
            Text("Price: \(priceFormatter.string(from: NSNumber(value: marketPost.price)) ?? "")")
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}
