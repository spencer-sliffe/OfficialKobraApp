//
//  ChatViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/11/23.
//

import Foundation


class ChatViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var messages: [String]?
    
    init() {
        isLoading = true
        
        // Simulate fetching messages from Firebase
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.messages = [                "Hello, how are you?",                "I'm doing well, thanks for asking!",                "That's great to hear. What's new?",                "Not much, just working on a new project.",                "That sounds interesting. Tell me more!",            ]
            self.isLoading = false
        }
    }
}


