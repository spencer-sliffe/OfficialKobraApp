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
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.posts.sorted(by: { $0.timestamp > $1.timestamp })) { post in
                        PostRow(post: post)
                            .environmentObject(viewModel)
                            .background(Color.clear)
                    }
                }
                .padding(.top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.black, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
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
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
            }
                .padding(16),
            alignment: .bottomTrailing
        )
    }
}


extension View {
    func listBackground(_ color: Color) -> some View {
        modifier(ListBackgroundModifier(color: color))
    }
}

private struct ListBackgroundModifier: ViewModifier {
    let color: Color

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .background(color)
            .listRowBackground(color)
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
                UITableViewCell.appearance().backgroundColor = .clear
            }
    }
}
