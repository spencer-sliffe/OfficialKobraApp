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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) { message in
                        MessageCell(message: message, isCurrentUser: message.senderId == viewModel.accountId)
                    }
                }
            }

            HStack {
                TextField("Type a message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Send") {
                    viewModel.sendMessage(text: messageText)
                    messageText = ""
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.primary)  // Adjust color as needed
        })
        .gesture(DragGesture()
            .onEnded { gesture in
                if gesture.translation.width > 100 {
                    // Swipe to the right, dismiss the view
                    presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }
}
