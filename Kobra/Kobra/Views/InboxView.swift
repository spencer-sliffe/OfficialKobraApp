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
    @State private var searchText = ""
    @State private var userEmail = ""
    @State private var showingAddChat = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            content
            
            addButton
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddChat, content: addChatSheet)
        .alert(isPresented: $showAlert, content: alert)
        .background(Color.clear)
    }

    private var content: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if sortedChats.isEmpty {
                Text("No Chats Currently")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
            } else {
                chatList
                    .searchable(text: $searchText)
                    .padding(.top, -10)
            }
        }
    }


    private var sortedChats: [Chat] {
        viewModel.chats.sorted { (chat1, chat2) -> Bool in
            let timestamp1 = chat1.lastMessage?.timestamp ?? Date.distantPast
            let timestamp2 = chat2.lastMessage?.timestamp ?? Date.distantPast
            return timestamp1 > timestamp2
        }
    }

    private var chatList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(sortedChats.filter({ searchText.isEmpty ? true : $0.otherParticipantEmail(for: viewModel.currentUserEmail).localizedCaseInsensitiveContains(searchText) })) { chat in
                        NavigationLink(
                            destination: ChatView(chat: chat),
                            label: {
                                ChatCell(chat: chat, unreadMessageCount: viewModel.unreadMessageCounts[chat.id] ?? 0) .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 0)
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                }
                .foregroundColor(.white)
                .listStyle(PlainListStyle())
            }
        }
        .refreshable {
            viewModel.fetchChats()
        }
    }


    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showingAddChat.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
        }
    }

    
    private func alert() -> Alert {
        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
    }

    private func addChatSheet() -> some View {
        VStack {
            TextField("Enter user email", text: $userEmail)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Add Chat") {
                viewModel.addChat(withUserEmail: userEmail) { result in
                    switch result {
                    case .success(_):
                        print("Chat added successfully.")
                        
                    case .failure(let error):
                        print("Failed to add chat: \(error.localizedDescription)")
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                }
                userEmail = ""
                showingAddChat.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.black, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct ChatCell: View {
    let chat: Chat
    let unreadMessageCount: Int
    
    var body: some View {
        ZStack {
            Color.clear
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    let emailComponents = chat.otherParticipantEmail(for: Auth.auth().currentUser?.email ?? "").split(separator: "@")
                    let displayName = String(emailComponents[0]).uppercased()
                    Text(displayName)
                        .font(.headline)
                    if let lastMessage = chat.lastMessage {
                        HStack(spacing: 4) {
                            let emailComponents2 = lastMessage.sender.split(separator: "@")
                            let displayName2 = String(emailComponents2[0]).uppercased()
                            Text(displayName2 + ":")
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
                
                if unreadMessageCount > 0 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .overlay(Text("\(unreadMessageCount)").foregroundColor(.white).font(.system(size: 12)))
                }
            }
        }
        .foregroundColor(.white)
        .background(Color.clear) // set the background to clear color
    }
}



struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = InboxViewModel()
        return InboxView(viewModel: viewModel)
    }
}
