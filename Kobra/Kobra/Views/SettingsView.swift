//
//  MarketPlaceView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/26/23.
//
import Foundation
import SwiftUI
import SwiftUI

struct SettingsView: View {
    @State private var isExpanded = false
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @StateObject var authViewModel: AuthenticationViewModel
    @State private var showChangePasswordView = false
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .padding(.bottom, 20)
                .foregroundColor(Color.white)

            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading) {
                    Text("Background Gradient")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white)

                    DropDownMenu(
                        isExpanded: $isExpanded,
                        options: gradientOptions.indices.map { "Gradient \($0 + 1)" },
                        selection: .constant("Gradient \(settingsViewModel.gradientIndex + 1)"),
                        onOptionSelected: { index in
                            settingsViewModel.updateSelectedGradient(to: index)
                        }
                    )
                }

                Text("Account")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)

                VStack(alignment: .leading) {
                    CustomButton(title: "Change Password") {
                        showChangePasswordView.toggle()
                    }
                    .sheet(isPresented: $showChangePasswordView) {
                        ChangePasswordView()
                    }
                    Spacer()
                    CustomButton(title: "Logout") {
                        showAlert = true // Call the signOut method on the injected view model
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .alert(isPresented: $showAlert) {
                   Alert(title: Text("Log Out"),
                         message: Text("Are you sure you want to log out?"),
                         primaryButton: .default(Text("Yes"), action: {
                             authViewModel.signOut()
                         }),
                         secondaryButton: .cancel())
               }
    }
}
