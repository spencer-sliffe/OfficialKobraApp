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
    @State private var selectedFeed: FeedType = .advertisement
    
    private func customToolbar() -> some View {
        HStack(spacing: 20) {
            ForEach(FeedType.allCases) { feedType in
                Button(action: {
                    selectedFeed = feedType
                }) {
                    VStack {
                       
                        if(feedType.rawValue == "Advertisement") {
                            Image(systemName: "radio") // Replace with appropriate icons
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(.bottom, 5)
                        } else if(feedType.rawValue == "Market") {
                            Image(systemName: "dollarsign.circle") // Replace with appropriate icons
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(.bottom, 5)
                        } else if(feedType.rawValue == "News") {
                            Image(systemName: "newspaper") // Replace with appropriate icons
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(.bottom, 5)
                        } else if(feedType.rawValue == "Help") {
                            Image(systemName: "questionmark.circle") // Replace with appropriate icons
                                .resizable()
                                .frame(width: 30, height:30)
                                .foregroundColor(selectedFeed == feedType ? .yellow : .white)
                                .padding(.bottom, 5)
                        }
                    }
                    .background(Color.clear)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    
    enum FeedType: String, CaseIterable, Identifiable {
        case advertisement = "Advertisement"
        case help = "Help"
        case news = "News"
        case market = "Market"
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
                    
                    Text("Kobra Feed")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Date(), formatter: timeFormatter)")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }.frame(height: 20)
            Spacer()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.posts.sorted(by: { $0.timestamp > $1.timestamp })) { post in
                        PostRow(post: post)
                            .environmentObject(viewModel)
                            .background(Color.clear)
                    }
                }
            }
            .background(Color.clear)
            
            customToolbar()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.black, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .edgesIgnoringSafeArea(.bottom)
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

