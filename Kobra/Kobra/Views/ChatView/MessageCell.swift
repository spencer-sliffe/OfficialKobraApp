//
//  MessageCell.swift
//  Kobra
//
//  Created by Spencer Sliffe on 6/22/23.
//

import Foundation
import SwiftUI

struct MessageCell: View {
    var message: Message
    var isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            } else {
                Text(message.text)
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                Spacer()
            }
        }
    }
}
