//  PostView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/5/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

/*struct PostView: View {
    @ObservedObject var post: Post
    @State private var isLiked = false
    @State private var likes = 0
    @State private var isDisliked = false
    @State private var dislikes = 0
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @State private var showingComments = false
    @State private var showingFullImage = false
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
        ScrollView {
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
                    Button(action: {
                        showingFullImage.toggle()
                    }) {
                        PostContent(title: post.title,
                                    content: post.content,
                                    imageURL: post.imageURL)
                        .scaledToFit()
                    }
                    .fullScreenCover(isPresented: $showingFullImage) {
                        Image(uiImage: post.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                showingFullImage.toggle()
                            }
                    }
                }
                
                HStack {
                    Button(action: canLike ? like : unlike) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("\(likes)")
                    
                    Button(action: canDislike ? dislike : undislike) {
                        Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("\(dislikes)")
                    
                    Button(action: { showingComments.toggle() }) {
                        Image(systemName: "bubble.right")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if showingComments {
                    CommentView(post: post)
                        .environmentObject(kobraViewModel)
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
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Deletion"),
                    message: Text("Are you sure you want to delete this post? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        kobraViewModel.deletePost(postId: post.id)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            fetchProfilePicture()
        }
    }
    
    private func like() {
        kobraViewModel.likePost(postId: post.id, userId: currentUserId)
        isLiked = true
        likes += 1
        if isDisliked {
            undislike()
        }
    }
    
    private func unlike() {
        kobraViewModel.unlikePost(postId: post.id, userId: currentUserId)
        isLiked = false
        likes -= 1
    }
    
    private func dislike() {
        kobraViewModel.dislikePost(postId: post.id, userId: currentUserId)
        isDisliked = true
        dislikes += 1
        if isLiked {
            unlike()
        }
    }
    
    private func undislike() {
        kobraViewModel.undislikePost(postId: post.id, userId: currentUserId)
        isDisliked = false
        dislikes -= 1
    }
    
    private func deletePost() {
        showingDeleteConfirmation = true
    }
    
    private func fetchProfilePicture() {
        if let profileUrl = post.profileURL {
            profilePictureURL = URL(string: profileUrl)
        }
    }
    
    private func canLike() -> Bool {
        return !post.likingUsers.contains(currentUserId)
    }
    
    private func canDislike() -> Bool {
        return !post.dislikingUsers.contains(currentUserId)
    }
    
    private func PostContent(title: String, content: String, imageURL: String?) -> some View {
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
    
    private func MarketPostContent(marketPost: MarketPost, imageURL: String?) -> some View {
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
                    ```swift
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
            
            Text("Price: \(priceFormatter.string(from: NSNumber(value: marketPost.price)) ?? "")")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Text("Category: \(marketPost.category)")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
    
    private var canLike: Bool {
        canLike()
    }
    
    private var canDislike: Bool {
        canDislike()
    }
}
*/
