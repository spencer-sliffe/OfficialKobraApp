//
//  FoodView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/19/23.
//

import Foundation
import SwiftUI

struct FoodView: View {
    @ObservedObject var viewModel = FoodViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                // Display your data here.
                // Replace with the appropriate logic for the Food view.
                Text("Food Content Here")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }

            Spacer()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Add the logic for displaying the contents for Food view here.
                }
            }
            .background(Color.clear)
        }
        .background(Color.clear)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
    }
}
