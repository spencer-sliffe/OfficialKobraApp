//
//  ChatView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23.
//
import SwiftUI
import Combine

struct ChatView: View {
    @ObservedObject var viewModel = ChatViewModel()
    @State private var chatInput = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var showSearchBar = false
    @State private var searchButtonLabel = "Cancel"

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
                    Spacer()
                    if !showSearchBar {
                        Button(action: {
                            self.showSearchBar.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .padding(.top, 0)
                                .padding(.horizontal)
                        }
                    } else if showSearchBar {
                        TextField("Search for other app users by email", text: $viewModel.searchQuery)
                            .background(Color.white.opacity(0.5))
                            .padding(.top, 0.1)
                            .padding(.horizontal, 5)
                            .font(.headline)
                        if !viewModel.searchQuery.isValidEmail()    {
                            Button(action:{self.showSearchBar.toggle()}) {Text("Cancel")}.padding(.horizontal, 10)
                        }
                        else if viewModel.searchQuery.isValidEmail() {
                            Button(action:{viewModel.searchUsers(email: viewModel.searchQuery)}) {Text("Search")}.padding(.horizontal, 10)
                        }
                    }
                }
                
                List(viewModel.messages ?? [], id: \.self) { message in
                    Text(message)
                }
                
                Spacer()
                
                HStack {
                    TextField("Message...", text: $chatInput)
                        .padding(.horizontal, 10)
                        .background(Color.white)
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Text("Send")
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, keyboardHeight)
                
            }
        }
        
        .onTapGesture {
            self.showSearchBar = false
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onReceive(viewModel.$searchQuery) { _ in
            self.searchButtonLabel = viewModel.searchQuery.isEmpty ? "Cancel" : "Search"
        }
        .onReceive(Publishers.keyboardHeight) {
            self.keyboardHeight = $0
        }
        .onAppear {
            viewModel.fetchMessages()
        }
    }
    
    private func sendMessage() {
        viewModel.sendMessage(chatInput)
        chatInput = ""
    }
}




struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

extension String {
    func isValidEmail() -> Bool {
        // Split the email address into two parts: the username and domain name
        let emailParts = self.split(separator: "@")
        
        // Make sure there are exactly two parts
        guard emailParts.count == 2 else { return false }
        
        // Make sure the username part is not empty
        let username = emailParts[0]
        guard !username.isEmpty else { return false }
        
        // Make sure the domain name part is not empty
        let domainName = emailParts[1]
        guard !domainName.isEmpty else { return false }
        
        // Make sure the domain name part contains at least one period
        let domainNameParts = domainName.split(separator: ".")
        guard domainNameParts.count > 1 else { return false }
        
        // Make sure each part of the domain name is not empty
        for domainNamePart in domainNameParts {
            guard !domainNamePart.isEmpty else { return false }
        }
        
        // If all the checks pass, the email is valid
        return true
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

