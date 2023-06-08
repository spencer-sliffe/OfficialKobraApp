//
//  AccountPostRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/4/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct AccountPostRow: View {
    @ObservedObject var post: Post
    @State private var isLiked = false
    @State private var likes = 0
    @State private var isDisliked = false
    @State private var dislikes = 0
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @State private var showingComments = false
    @State private var showingDeleteAlert = false
    
    // Add a property for the current user's ID
    let currentUserId: String = Auth.auth().currentUser?.uid ?? ""
    
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(getPosterName())
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Text(post.timestamp.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    showingDeleteAlert.toggle()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                
            }
            
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
            case .market(let marketPost):
                MarketPostContent(marketPost: marketPost, imageURL: post.imageURL)
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
                    kobraViewModel.updateLikeCount(post, likeCount: likes, userId: currentUserId, isAdding: isLiked)
                }) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(likes)")
                            .foregroundColor(.primary)
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
                    kobraViewModel.updateDislikeCount(post, dislikeCount: dislikes, userId: currentUserId, isAdding: isDisliked)
                }) {
                    HStack {
                        Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .foregroundColor(isDisliked ? .red : .gray)
                        Text("\(dislikes)")
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
                Button(action: {
                    showingComments.toggle()
                }) {
                    HStack {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("Comment")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.6))
        .border(Color(.separator), width: 1)
        .cornerRadius(8)
        .sheet(isPresented: $showingComments) {
            CommentView(viewModel: kobraViewModel, post: post)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(title: Text("Delete Post"),
                  message: Text("Are you sure you want to delete this post?"),
                  primaryButton: .destructive(Text("Delete")) {
                kobraViewModel.deletePost(post)
            },
                  secondaryButton: .cancel())
        }
    }
    
    
    func getPosterName() -> String {
        switch post.type {
        case .advertisement(let advertisementPost):
            return "Advertisement by \(advertisementPost.poster)"
        case .help(let helpPost):
            return "Help Request by \(helpPost.poster)"
        case .news(let newsPost):
            return "Article by \(newsPost.poster)"
        case .market(let marketPost):
            return "Product by \(marketPost.vendor)"
        }
    }
    
    func canLike() -> Bool {
        return !post.likingUsers.contains(currentUserId)
    }
    
    // Add a function to check if the user can dislike the post
    func canDislike() -> Bool {
        return !post.dislikingUsers.contains(currentUserId)
    }
    
    
    func PostContent(title: String, content: String, imageURL: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 300)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
    
    func MarketPostContent(marketPost: MarketPost, imageURL: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
                Text(other.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text("Other: \(other.title)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 300)
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
