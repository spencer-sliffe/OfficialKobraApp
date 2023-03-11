//
// AccountView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//

import SwiftUI
import Firebase

struct AccountView: View {
    @ObservedObject var viewModel = AccountViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let account = viewModel.account {
                    Text("Welcome Back \(account.email)")
                        .font(.largeTitle)
                    if let package = account.package {
                        Text("Current Subscription: \(package.name)")
                        Text("Price: \(package.price)")
                    } else {
                        Text("Current Subscription: none")
                    }
                } else {
                    Text("Failed to fetch account data")
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .navigationBarTitle("")
        }
    }
}


struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
