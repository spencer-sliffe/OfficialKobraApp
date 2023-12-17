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
    @EnvironmentObject var inboxViewModel: InboxViewModel
    @EnvironmentObject var homePageViewModel: HomePageViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showingCreateChat = false
    
    var body: some View {
        VStack(spacing: 0) {
            if inboxViewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(inboxViewModel.chats.sorted(by: { $0.timestamp > $1.timestamp })) { chat in
                            NavigationLink(destination: ChatView(viewModel: ChatViewModel(chatId: chat.id.uuidString, chatName: chat.username))
                                .environmentObject(settingsViewModel)) {
                                ChatCell(chat: chat)
                            }
                        }
                    }
                }
                .refreshable {
                    inboxViewModel.fetchInbox()
                }
            }
            Spacer()
            
            // Floating Action Button
            HStack {
                Spacer()
                Button(action: { showingCreateChat = true }) {
                    Image(systemName: "plus.message")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
                .accessibilityLabel("Create new chat")
            }
        }
        .sheet(isPresented: $showingCreateChat) {
            CreateChatView()
                .environmentObject(inboxViewModel)
        }
        .onAppear() {
            inboxViewModel.fetchInbox()
        }
    }
}

