//
//  InboxView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/18/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct InboxView: View {
    @ObservedObject var viewModel: InboxViewModel
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    NavigationView {
                        List(viewModel.chats.filter({ viewModel.searchText.isEmpty ? true : $0.otherParticipantEmail(for: viewModel.currentUserEmail).localizedCaseInsensitiveContains(viewModel.searchText) })) { chat in
                            NavigationLink(destination: ChatView(chat: chat)) {
                                ChatCell(chat: chat)
                            }.listRowBackground(Color.clear)
                        }
                        .listStyle(PlainListStyle())
                        .searchable(text: $viewModel.searchText, prompt: "Search")
                        .background(LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .onAppear {
                            viewModel.fetchChats()
                        }
                    }
                    .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .navigationBarHidden(true)
                }
        } .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct ChatCell: View {
    let chat: Chat
    
    var body: some View {
        NavigationLink(destination: ChatView(chat: chat)) {
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.otherParticipantEmail(for: Auth.auth().currentUser?.email ?? ""))
                    .font(.headline)
                if let lastMessage = chat.lastMessage {
                    HStack(spacing: 4) {
                        Text(lastMessage.sender)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(lastMessage.text)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                        Text(lastMessage.timestamp, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 8)
            
        }
        .buttonStyle(PlainButtonStyle())
        .navigationBarTitle("", displayMode: .inline)
        
    }
}



struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = InboxViewModel()
        return InboxView(viewModel: viewModel)
    }
}
