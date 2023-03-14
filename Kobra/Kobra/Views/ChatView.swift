//
//  ChatView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23.
//

import Foundation
import SwiftUI
import Firebase
import Combine

struct ChatView: View {
    @ObservedObject var viewModel = ChatViewModel()
    @State private var chatInput: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var searchQuery: String = ""
    @State private var showSearchBar: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    if showSearchBar {
                        TextField("Search for other app users by email", text: $searchQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onTapGesture {
                                self.showSearchBar = true
                            }

                        Button(action: {
                            searchUsers()
                            self.showSearchBar = false // add this line
                        }) {
                            Text("Search")
                        }
                    } else {
                        Spacer()
                    }
                }
                .padding()

                if let searchResults = viewModel.searchResults {
                    List(searchResults, id: \.id) { result in
                        Button(action: { viewModel.startChat(with: result) }) {
                            HStack {
                                Text(result.email)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                } else if let messages = viewModel.messages {
                    List(messages, id: \.self) { message in
                        Text(message)
                            .background(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .listRowBackground(Color.clear)
                } else {
                    Text("Failed to fetch messages")
                }

                Spacer()

                // Chat input and send button code...

                // Plus button code..


                HStack {
                    TextField("Type your message", text: $chatInput)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                        }

                    Button(action: sendMessage) {
                        Text("Send")
                    }
                    .padding(.trailing)
                }
                .background(Color.white.opacity(0.7))
                .padding(.bottom, keyboardHeight)
                .animation(.easeInOut) // or .default, .spring(), etc.
                .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }

                if showSearchBar {
                    VStack(spacing: 16) {
                        if let searchResults = viewModel.searchResults {
                            List(searchResults, id: \.id) { result in
                                Button(action: { viewModel.startChat(with: result) }) {
                                    HStack {
                                        Text(result.email)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(16)
                    .transition(.move(edge: .top))
                }

            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { self.showSearchBar.toggle() }) {
                        Image(systemName: "plus")
                            .font(.title)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onTapGesture {
            self.showSearchBar = false
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private func sendMessage() {
        viewModel.sendMessage(chatInput)
        chatInput = ""
    }

    private func searchUsers() {
        viewModel.searchUsers(email: searchQuery)
    }
}

    

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}



extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

