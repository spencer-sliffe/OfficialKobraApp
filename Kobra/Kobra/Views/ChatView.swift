//
//  ChatView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23

import SwiftUI
import Combine
import Firebase

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var chatInput = ""
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages, id: \.self) { message in
                            MessageRow(message: message, isFromCurrentUser: message.sender == Auth.auth().currentUser?.email)
                        }
                    }
                    .onAppear(){
                        viewModel.fetchMessages()
                        viewModel.markMessagesAsRead()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        scrollView.scrollTo(viewModel.messages.last, anchor: .bottom)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            Divider()
            HStack(spacing: 0) {
                TextField("Message...", text: $chatInput)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
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
            .foregroundColor(Color.white)
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
        )
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

