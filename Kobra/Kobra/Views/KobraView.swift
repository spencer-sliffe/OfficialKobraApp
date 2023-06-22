//
//  KobraView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/26/23.
//

import SwiftUI
import Foundation

struct KobraView: View {
    @State private var isPresentingCreatePostView = false
    @ObservedObject var viewModel = KobraViewModel()
    @State private var selectedFeed: FeedType = .advertisement
    
    func isPostTypeVisible(post: Post) -> Bool {
        switch selectedFeed {
        case .advertisement:
            if case .advertisement = post.type { return true }
        case .help:
            if case .help = post.type { return true }
        case .news:
            if case .news = post.type { return true }
        case .market:
            if case .market = post.type { return true }
        case .bug:
            if case .bug = post.type { return true }
        case .meme:
            if case .meme = post.type { return true }
        }
        return false
    }
    
    private func customToolbar() -> some View {
        HStack(spacing: 20) {
            ForEach(FeedType.allCases) { feedType in
                Button(action: {
                    selectedFeed = feedType
                    viewModel.fetchPosts()
                }) {
                    VStack {
                        if(feedType.rawValue == "Advertisement") {
                            Image(systemName: "radio") // Replace with appropriate icons
                                .resizable()
                                .frame(width: selectedFeed == feedType ? 26 : 22, height: selectedFeed == feedType ? 26 : 22)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(0)
                        } else if(feedType.rawValue == "Market") {
                            Image(systemName: "dollarsign.circle") // Replace with appropriate icons
                                .resizable()
                                .frame(width: selectedFeed == feedType ? 26 : 22, height: selectedFeed == feedType ? 26 : 22)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(0)
                        } else if(feedType.rawValue == "News") {
                            Image(systemName: "newspaper") // Replace with appropriate icons
                                .resizable()
                                .frame(width: selectedFeed == feedType ? 26 : 22, height: selectedFeed == feedType ? 26 : 22)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(0)
                        } else if(feedType.rawValue == "Help") {
                            Image(systemName: "questionmark.circle") // Replace with appropriate icons
                                .resizable()
                                .frame(width: selectedFeed == feedType ? 26 : 22, height: selectedFeed == feedType ? 26 : 22)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(0)
                        } else if(feedType.rawValue == "Bug") {
                            Image(systemName: "ant") // Replace with appropriate icons
                                .resizable()
                                .frame(width: selectedFeed == feedType ? 26 : 22, height: selectedFeed == feedType ? 26 : 22)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(0)
                        } else if(feedType.rawValue == "Meme") {
                            Image(systemName: "photo") // Replace with appropriate icons
                                .resizable()
                                .frame(width: selectedFeed == feedType ? 26 : 22, height: selectedFeed == feedType ? 26 : 22)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(0)
                        }
                        
                    }
                    .background(Color.clear)
                }
            }
            Button(action: {
                isPresentingCreatePostView.toggle()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .foregroundColor(.white)
                    .padding(0)
            }
        }
        .padding(.bottom, 0)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    
    enum FeedType: String, CaseIterable, Identifiable {
        case advertisement = "Advertisement"
        case help = "Help"
        case news = "News"
        case market = "Market"
        case bug = "Bug"
        case meme = "Meme"
        var id: String { self.rawValue }
    }
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Text("\(Date(), formatter: dateFormatter)")
                        .foregroundColor(.white)
                    Spacer()
                    // Add a new condition to handle the title of the meme feed
                    if(selectedFeed.rawValue == "Meme") {
                        Text("Meme Feed")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else if(selectedFeed.rawValue == "Advertisement") {
                        Text("Advertisement Feed")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else if(selectedFeed.rawValue == "Market") {
                        Text("Market Feed")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else if(selectedFeed.rawValue == "News") {
                        Text("News Feed")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else if(selectedFeed.rawValue == "Help") {
                        Text("Help Feed")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else if(selectedFeed.rawValue == "Bug") {
                        Text("Bug Feed")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("\(Date(), formatter: timeFormatter)")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }.frame(height: 20)
            Spacer()
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.posts.sorted(by: { $0.timestamp > $1.timestamp }).filter(isPostTypeVisible)) { post in
                            PostRow(post: post)
                                .environmentObject(viewModel)
                                .background(Color.clear)
                        }
                    }
                }
                .padding(.trailing, 1)  // Add some padding to the right side of the ScrollView
                .background(Color.clear)
                .overlay(  // Add an overlay to the right side of the ScrollView
                    Color.clear
                        .frame(width: 1)  // Set width to the same value as the padding above
                        .edgesIgnoringSafeArea(.all), alignment: .trailing
                )
            }
            customToolbar()
        }
        .background(Color.clear)
        .onAppear {
            viewModel.fetchPosts()
        }
        .sheet(isPresented: $isPresentingCreatePostView) {
            CreatePostView().environmentObject(viewModel)
        }
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

