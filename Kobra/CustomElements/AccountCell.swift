//
//  UserCell.swift
//  Kobra
//
//  Created by Spencer SLiffe on 6/5/23.
//

import Foundation
import SwiftUI

struct AccountCell: View {
    var account: Account
    
    var body: some View {
        HStack {
            if let url = account.profilePicture {
                Image(url.absoluteString)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 60, height: 60)
                    .cornerRadius(30)
            } else {
                // Show a placeholder image or view when the profile picture is nil
            }
            
            Text(account.email)
                .font(.system(size: 15, weight: .semibold))
                .padding(.leading, 8)
        }
    }
}
