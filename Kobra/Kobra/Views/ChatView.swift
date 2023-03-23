//
//  ChatView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23.

import SwiftUI
import Combine
import Firebase
import FirebaseFirestore
import Foundation

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var chatInput = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var showSearchBar = false
    @State private var searchButtonLabel = "Cancel"
    @Environment(\.presentationMode) var presentationMode
    init(chat: Chat) {
        viewModel = ChatViewModel(chat: chat)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                GeometryReader { geometry in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.messages, id: \.self) { message in
                                MessageRow(message: message, isFromCurrentUser: message.sender == Auth.auth().currentUser?.email)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, keyboardHeight + 50) // Padding to accommodate the input field
                }
                
                VStack {
                    HStack {
                        TextField("Message...", text: $chatInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 40)
                        
                        Button(action: {
                            viewModel.sendMessage(chatInput)
                            chatInput = ""
                        }) {
                            Text("Send")
                        }
                        .padding(.horizontal)
                        .frame(height: 40)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .disabled(chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, keyboardHeight)
                    .background(Color.white)
                }
            }
        }
        .navigationBarTitle(viewModel.chat.otherParticipantEmail(for: Auth.auth().currentUser?.email ?? ""), displayMode: .inline)
        .onAppear {
            viewModel.fetchMessages()
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                if let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom {
                    keyboardHeight = value.height - safeAreaBottom
                } else {
                    keyboardHeight = value.height
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (_) in
                keyboardHeight = 0
            }
        }
        .onDisappear {
            viewModel.chatListener?.remove()
            NotificationCenter.default.removeObserver(self)
        }
    }
}

