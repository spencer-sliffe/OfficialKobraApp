//
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
    @EnvironmentObject var kobraViewModel: KobraViewModel
    
    var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(getPosterName())
                .font(.footnote)
                .foregroundColor(.white)
            switch post.type {
            case .advertisement(let advertisementPost):
                Text(advertisementPost.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(advertisementPost.content)
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .help(let helpPost):
                Text(helpPost.question)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(helpPost.details)
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .news(let newsPost):
                Text(newsPost.headline)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(newsPost.article)
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .market(let marketPost):
                switch marketPost.type {
                case .hardware(let hardware):
                    Text("Hardware: \(hardware.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(hardware.condition == .new ? "New" : "Used")
                        .foregroundColor(.white)
                    Text("Price: \(priceFormatter.string(from: NSNumber(value: marketPost.price)) ?? "")")
                        .foregroundColor(.white)
                case .software(let software):
                    Text("Software: \(software.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(software.description)
                        .foregroundColor(.white)
                    Text("Price: \(priceFormatter.string(from: NSNumber(value: marketPost.price)) ?? "")")
                        .foregroundColor(.white)
                    Text("Category: \(marketPost.category)")
                        .foregroundColor(.white)
                case .service(let service):
                    Text("Service: \(service.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(service.description)
                        .foregroundColor(.white)
                    Text("Price: \(priceFormatter.string(from: NSNumber(value: marketPost.price)) ?? "")")
                        .foregroundColor(.white)
                    Text("Category: \(marketPost.category)")
                        .foregroundColor(.white)
                case .other(let other):
                    Text("Other: \(other.title)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(other.description)
                        .foregroundColor(.white)
                    Text("Price: \(priceFormatter.string(from: NSNumber(value: marketPost.price)) ?? "")")
                        .foregroundColor(.white)
                }
            }
            Text(post.timestamp.formatted())
                .font(.caption)
                .foregroundColor(.white)
            HStack {
                Button(action: {
                    isLiked.toggle()
                    likes = post.likes + (isLiked ? +1 : +0)
                    kobraViewModel.updateLikeCount(post, likeCount: likes)
                }) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("Like")
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                Text("Likes: \(likes)")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .border(Color.white, width: 1)
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
}
