//
//  FoodRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/21/23.
//

import Foundation
import SwiftUI

struct FoodRow: View {
    @ObservedObject var food: Food
    @State private var isLiked = false
    @State private var likes = 0
    @EnvironmentObject var foodViewModel: FoodViewModel
    
    // Add a property for the current user's ID
    let currentUserId: String = "CurrentUser" // Replace this line with your actual authentication system
    
    init(food: Food) {
        self.food = food
        _likes = State(initialValue: food.likes)
        _isLiked = State(initialValue: food.likingUsers.contains(currentUserId))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(food.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Text(food.timestamp.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("Preparation time: \(food.preparationTime)")
                .font(.subheadline)
            Text("Ingredients: \(food.ingredients.joined(separator: ", "))")
                .font(.subheadline)
            ForEach(food.steps, id: \.self) { step in
                Text(step)
                    .font(.body)
            }
            
            if let image = UIImage(named: food.image) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                    .frame(maxHeight: 300)
            }
            
            HStack {
                Button(action: {
                    isLiked.toggle()
                    if isLiked {
                        likes += 1
                        food.likingUsers.append(currentUserId)
                    } else {
                        likes -= 1
                        food.likingUsers.removeAll { $0 == currentUserId }
                    }
                    foodViewModel.updateLikeCount(food, likeCount: likes, userId: currentUserId, isAdding: isLiked)
                }) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(likes)")
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
                // Add more actions (buttons) here if you need
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.6))
        .border(Color(.separator), width: 1)
        .cornerRadius(8)
    }
    
    func canLike() -> Bool {
        return !food.likingUsers.contains(currentUserId)
    }
}
