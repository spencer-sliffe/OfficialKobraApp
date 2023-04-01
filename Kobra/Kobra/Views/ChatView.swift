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
    @State private var showSearchBar = false
    @State private var searchButtonLabel = "Cancel"
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScrollViewReader { scrollView in
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages, id: \.self) { message in
                            MessageRow(message: message, isFromCurrentUser: message.sender == Auth.auth().currentUser?.email)
                        }
                    }
                    .onAppear(){
                        viewModel.fetchMessages()
                        viewModel.markMessagesAsRead()
                    }
                    .onChange(of: viewModel.messages.count, perform: { _ in
                        scrollView.scrollTo(viewModel.messages.count - 1)
                    })
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            
            
            Divider()
            
            HStack(spacing: 0) {
                TextField("Message...", text: $chatInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 40)
                Button(action: {
                    viewModel.sendMessage(chatInput)
                    chatInput = ""
                }) {
                    Text("Send")
                }
                .frame(width: 80, height: 40)
                .background(Color.clear)
                .cornerRadius(10)
                .disabled(chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .foregroundColor(Color.gray)
            .padding(.horizontal)
            .background(Color.clear)
            .padding(.bottom, keyboardHeight)
        }
        .keyboardAware()
        .navigationBarTitle(Text(viewModel.chat.otherParticipantEmail(for: Auth.auth().currentUser?.email ?? "").split(separator: "@").first?.uppercased() ?? ""), displayMode: .inline)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchMessages()
        }
        .onDisappear {
            viewModel.chatListener?.remove()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.black, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                    let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    self.keyboardHeight = value.height
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                    self.keyboardHeight = 0
                }
            }
    }
}


extension View {
    func keyboardAware() -> ModifiedContent<Self, KeyboardAwareModifier> {
        return modifier(KeyboardAwareModifier())
    }
}
