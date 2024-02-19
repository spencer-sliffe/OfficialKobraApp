//
//  MarketPostContent.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/19/24.
//

import Foundation
import SwiftUI

struct MarketPostContent: View {
    let marketPost: MarketPost
    let imageURL: String?
    let videoURL: String?
    
    var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
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
            }
            
            if let videoURL = videoURL, let url = URL(string: videoURL) {
                VideoPlayerView(videoURL: url, shouldPlay: .constant(false), isInView: .constant(false))
                    .frame(height: 300)
                    .contentShape(Rectangle())
            }
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
            Text("Price: \(priceFormatter.string(from: NSNumber(value: marketPost.price)) ?? "")")
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

