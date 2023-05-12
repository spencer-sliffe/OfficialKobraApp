//
//  PasswordResetView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/2/23
//

import Foundation
import SwiftUI
import Firebase

struct ChangePasswordView: View {
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Reset Password")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .padding(.bottom, 20)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
                .font(.system(size: 18))
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button(action: {
                resetPassword()
            }) {
                Text("Send Reset Link")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .font(.system(size: 20))
                    .padding(.horizontal, 30)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Password Reset"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "A password reset link has been sent to your email."
            }
            showAlert.toggle()
        }
    }
}
