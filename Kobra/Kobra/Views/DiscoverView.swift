//
//  DiscoverView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/18/23.
//

import Foundation
import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel = DiscoverViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                // Display your data here.
                // Replace with the appropriate logic for the Discover view.
                Text("Discover Content Here")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }

            Spacer()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Add the logic for displaying the contents for Discover view here.
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