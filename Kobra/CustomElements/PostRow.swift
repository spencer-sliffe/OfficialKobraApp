//  PostRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/1/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct PostRow: View {
    @ObservedObject var post: Post
    @State private var isLiked = false
    @State private var likes = 0
    @State private var isDisliked = false
    @State private var dislikes = 0
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @State private var showingComments = false
    @State private var showingFullImage = false // new state for full screen image
    let currentUserId: String = Auth.auth().currentUser?.uid ?? ""
    @State private var showingDeleteConfirmation = false
    @State private var profilePictureURL: URL?
    
    init(post: Post) {
        self.post = post
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
                NavigationLink(destination: AccountProfileView(accountId: post.posterId)) {
                    getPosterName()
                }
                Spacer()
                Text(post.timestamp.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if currentUserId == post.posterId {
                    Button(action: deletePost) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            VStack {
                switch post.type {
                case .advertisement(let advertisementPost):
                    PostContent(title: advertisementPost.title,
                                content: advertisementPost.content,
                                imageURL: post.imageURL)
                case .help(let helpPost):
                    PostContent(title: helpPost.question,
                                content: helpPost.details,
                                imageURL: post.imageURL)
                case .news(let newsPost):
                    PostContent(title: newsPost.headline,
                                content: newsPost.article,
                                imageURL: post.imageURL)
                case .bug(let bugPost):
                    PostContent(title: bugPost.title,
                                content: bugPost.content,
                                imageURL: post.imageURL)
                case .meme(let memePost):
                    PostContent(title: memePost.title,
                                content: memePost.content,
                                imageURL: post.imageURL)
                case .market(let marketPost):
                    MarketPostContent(marketPost: marketPost, imageURL: post.imageURL)
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
                            .foregroundColor(.primary)
                            .font(.caption)
                            .padding(5)
                            .background(Color.red.opacity(0.1))
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
                            .foregroundColor(.primary)
                            .font(.caption)
                            .padding(5)
                            .background(Color.black.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
                Spacer()
                Button(action: {
                    showingComments.toggle()
                }) {
                    HStack {
                        Text("\(post.numComments)")
                            .foregroundColor(.primary)
                            .font(.caption)
                            .padding(5)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.blue, lineWidth: 1)
                            )
                        Image(systemName: "bubble.right")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .sheet(isPresented: $showingComments) {
            CommentView(post: post).environmentObject(kobraViewModel)
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
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(.gray))
                }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(.gray))
            }
            
            switch post.type {
            case .advertisement(let advertisementPost):
                Text("Ad : ")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.purple) +
                Text(advertisementPost.poster)
                    .font(.headline)
                    .foregroundColor(.blue)
            case .help(let helpPost):
                Text("Help : ")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green) +
                Text(helpPost.poster)
                    .font(.headline)
                    .foregroundColor(.blue)
            case .news(let newsPost):
                Text("News : ")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.red) +
                Text(newsPost.poster)
                    .font(.headline)
                    .foregroundColor(.blue)
            case .bug(let bugPost):
                Text("Bug : ")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange) +
                Text(bugPost.poster)
                    .font(.headline)
                    .foregroundColor(.blue)
            case .meme(let memePost):
                Text("Meme : ")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.pink) +
                Text(memePost.poster)
                    .font(.headline)
                    .foregroundColor(.blue)
            case .market(let marketPost):
                Text("Item : ")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow) +
                Text(marketPost.vendor)
                    .font(.headline)
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
    
    func PostContent(title: String, content: String, imageURL: String?) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 2)) // Add outline around the image
                        .onLongPressGesture {
                            showingFullImage = true
                        }
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 300)
                .fullScreenCover(isPresented: $showingFullImage) {
                    ZStack {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingFullImage = false
                        }
                    }
                }
            }
            Text(content)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }

    
    func MarketPostContent(marketPost: MarketPost, imageURL: String?) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            switch marketPost.type {
            case .hardware(let hardware):
                Text("Hardware: \(hardware.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(hardware.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            case .software(let software):
                Text("Software: \(software.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(software.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            case .service(let service):
                Text("Service: \(service.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(service.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            case .other(let other):
                Text("Other: \(other.title)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(other.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 2)) // Add outline around the image
                        .onLongPressGesture {
                            showingFullImage = true
                        }
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 300)
                .fullScreenCover(isPresented: $showingFullImage) {
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
                }
            }
            
            Text("Price: \(priceFormatter.string(from: NSNumber(value: marketPost.price)) ?? "")")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Text("Category: \(marketPost.category)")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}
