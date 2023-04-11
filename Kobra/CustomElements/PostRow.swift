//  PostRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/1/23.
//

import Foundation
import SwiftUI

struct PostRow: View {
    var post: Post
    @State private var isLiked = false
    @State private var likes = 0
    @State private var isDisliked = false
    @State private var dislikes = 0
    @EnvironmentObject var kobraViewModel: KobraViewModel
    
    init(post: Post) {
        self.post = post
        _likes = State(initialValue: post.likes)
        _dislikes = State(initialValue: post.dislikes)
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
                    } else {
                        likes -= 1
                    }
                    kobraViewModel.updateLikeCount(post, likeCount: likes)
                }) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("Like")
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
                Text("Likes: \(likes)")
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    isDisliked.toggle()
                    if isDisliked {
                        dislikes += 1
                    } else {
                        dislikes -= 1
                    }
                    kobraViewModel.updateDislikeCount(post, dislikeCount: dislikes)
                }) {
                    HStack {
                        Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .foregroundColor(isDisliked ? .red : .gray)
                        Text("Dislike")
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
                Text("Dislikes: \(dislikes)")
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.6))
        .border(Color(.separator), width: 1)
        .cornerRadius(8)
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
