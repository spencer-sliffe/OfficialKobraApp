//
//  ChatView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/11/23.
//

import Foundation
import SwiftUI
import Firebase

struct ChatView: View {
    @ObservedObject var viewModel = ChatViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let messages = viewModel.messages {
                List(messages, id: \.self) { message in
                    Text(message)
                }
            } else {
                Text("Failed to fetch messages")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
