//
//  FoodRow.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/21/23.
//

import Foundation
import SwiftUI

struct FoodRow: View {
    var food: Food

    var body: some View {
        VStack(alignment: .leading) {
            Text(food.name)
                .font(.headline)
            Text("Preparation time: \(food.preparationTime)")
                .font(.subheadline)
            Text("Ingredients: \(food.ingredients.joined(separator: ", "))")
                .font(.subheadline)
            ForEach(food.steps, id: \.self) { step in
                Text(step)
                    .font(.body)
            }
            Image(food.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .padding()
    }
}
