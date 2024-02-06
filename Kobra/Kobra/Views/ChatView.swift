//
//  ChatView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23

import SwiftUI
import Combine

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var messageText = ""
    @State private var isAtBottom = true
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(viewModel.messages) { message in
                            MessageCell(message: message, isCurrentUser: message.senderId == viewModel.accountId)
                                .id(message.id)
                        }
                    }
                    .onChange(of: viewModel.messages) { _ in
                        scrollToBottom(with: scrollViewProxy)
                    }
                    .onAppear {
                        scrollToBottom(with: scrollViewProxy)
                    }
                }
            }

            MessageInputView(text: $messageText) {
                viewModel.sendMessage(text: messageText)
                messageText = ""
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
        .navigationBarTitle(Text(viewModel.formattedChatName), displayMode: .inline) 
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        gradientOptions[settingsViewModel.gradientIndex].0,
                        gradientOptions[settingsViewModel.gradientIndex].1
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear() {
            viewModel.markMessagesAsRead()
        }
    }

    private func scrollToBottom(with scrollViewProxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

struct MessageInputView: View {
    @Binding var text: String
    var onSend: () -> Void

    var body: some View {
        HStack {
            TextField("Message", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(8)

            Button(action: onSend) {
                Text("Send")
            }
            .disabled(text.isEmpty)
        }
        .padding(.horizontal)
    }
}

