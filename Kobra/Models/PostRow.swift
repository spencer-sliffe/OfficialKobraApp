//
//  PostRow.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/1/23.
//

import Foundation
import SwiftUI

struct PostRow: View {
    var post: Post
    @State private var isLiked = false
    @State private var likes = 0
    @EnvironmentObject var kobraViewModel: KobraViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(getPosterName())
                           .font(.footnote)
                           .foregroundColor(.gray)
            switch post.type {
            case .advertisement(let advertisementPost):
                Text(advertisementPost.title)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(advertisementPost.content)
                    .font(.subheadline)
            case .help(let helpPost):
                Text(helpPost.question)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(helpPost.details)
                    .font(.subheadline)
            case .news(let newsPost):
                Text(newsPost.headline)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(newsPost.article)
                    .font(.subheadline)
            case .market(let marketPost):
                switch marketPost.type {
                case .hardware(let hardware):
                    Text("Hardware: \(hardware.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(hardware.condition == .new ? "New" : "Used")
                    Text("Price: \(hardware.price)")
                case .software(let software):
                    Text("Software: \(software.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(software.description)
                    Text("Price: \(software.price)")
                    Text("Category: \(software.category)")
                case .service(let service):
                    Text("Service: \(service.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(service.description)
                    Text("Price: \(service.price)")
                    Text("Category: \(service.category)")
                case .other(let other):
                    Text("Other: \(other.title)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(other.description)
                }
            }
            HStack {
                Button(action: {
                    isLiked.toggle()
                    likes = post.likes + (isLiked ? 1 : 0)
                    kobraViewModel.updateLikeCount(for: post.id, likeCount: likes)
                }) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("Like")
                    }
                }
                Spacer()
                Text("Likes: \(likes)")
            }
        }
        .padding()
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
}
