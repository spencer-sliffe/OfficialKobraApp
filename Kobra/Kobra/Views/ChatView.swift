//
//  ChatView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23

import SwiftUI
import Combine

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var messageText = ""
    @State private var isAtBottom = true
    
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
        .navigationBarTitle(Text(viewModel.chatName), displayMode: .inline)
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
