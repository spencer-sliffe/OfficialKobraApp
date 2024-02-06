//
//  CreateChatView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 12/5/23.
//

import Foundation
import SwiftUI

struct CreateChatView: View {
    @EnvironmentObject var viewModel: InboxViewModel
    @State private var enteredUsername = ""
    @State private var addedUsers = [String]()
    @State private var isUsernameValid = false
    @State private var chatName = "" // State for the chat name

    
    var body: some View {
        VStack {
            TextField("Enter username", text: $enteredUsername)
                .onChange(of: enteredUsername) { newValue in
                    validateUsername(username: newValue)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Add User") {
                addUser()
            }
            .opacity(isUsernameValid ? 1 : 0.5)
            .disabled(!isUsernameValid)
            .padding()

            // Conditional TextField for chat name
            if addedUsers.count > 1 {
                TextField("Enter chat name", text: $chatName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            Button("Create Chat") {
                createChat()
            }
            .disabled(addedUsers.isEmpty || (addedUsers.count > 1 && chatName.isEmpty))
            .padding()

            List(addedUsers, id: \.self) { user in
                Text(user)
            }
        }
    }

    private func validateUsername(username: String) {
        viewModel.checkIfUserNameValid(username: username) { result in
            switch result {
            case .success(_):
                isUsernameValid = true
            case .failure(_):
                isUsernameValid = false
            }
        }
    }

    private func addUser() {
        if isUsernameValid {
            addedUsers.append(enteredUsername)
            enteredUsername = ""
            isUsernameValid = false
        }
    }

    private func createChat() {
        viewModel.addChat(participants: addedUsers) { result in
            switch result {
            case .success():
                print("Chat created successfully.")
                // Handle successful chat creation
            case .failure(let error):
                print("Error creating chat: \(error.localizedDescription)")
                // Handle error
            }
        }
    }
}
