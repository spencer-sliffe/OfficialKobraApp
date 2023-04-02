//
//  KobraView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/26/23.
//

import SwiftUI
import Foundation

struct KobraView: View {
    @State private var isPresentingCreatePostView = false
    @ObservedObject var viewModel = KobraViewModel()
    
    var body: some View {
        VStack {
            List(viewModel.posts) { post in
                PostRow(post: post)
                    .environmentObject(viewModel)
            }
        }
        .navigationBarTitle("Kobra Feed")
        .onAppear {
            viewModel.fetchPosts()
        }
        .sheet(isPresented: $isPresentingCreatePostView) {
            CreatePostView().environmentObject(viewModel)
        }
        .overlay(
            Button(action: {
                isPresentingCreatePostView.toggle()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
            }
                .padding(.bottom, 20),
            alignment: .bottomTrailing
        )
    }
}
