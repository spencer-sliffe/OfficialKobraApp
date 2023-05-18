//
//  MarketPlaceView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/26/23.
//
import Foundation
import SwiftUI

struct SettingsView: View {
    @State private var isGradientExpanded = false
    @State private var isLanguageExpanded = false
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
                
                GradientDropDownMenu(
                    isExpanded: $isGradientExpanded,
                    options: gradientOptions.indices.map {
                        let gradient = LinearGradient(gradient: Gradient(colors: [gradientOptions[$0].0, gradientOptions[$0].1]), startPoint: .leading, endPoint: .trailing)
                        return ("Gradient \($0 + 1)", gradient)
                    },
                    selection: .constant("Gradient \(settingsViewModel.gradientIndex + 1)"),
                    onOptionSelected: { index in
                        settingsViewModel.updateSelectedGradient(to: index)
                    }
                )
                .onChange(of: isLanguageExpanded) { value in
                    if value {
                        isGradientExpanded = false
                    }
                }
                
                Toggle(isOn: $settingsViewModel.isDarkMode) {
                    Text("Dark Mode")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white)
                }
                Toggle(isOn: $settingsViewModel.pushNotificationsEnabled) {
                    Text("Push Notifications")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white)
                }
                
                DropDownMenu(
                    isExpanded: $isLanguageExpanded,
                    options: settingsViewModel.languages,
                    selection: $settingsViewModel.selectedLanguage,
                    onOptionSelected: { index in
                        settingsViewModel.updateSelectedLanguage(to: index)
                    }
                )
                .onChange(of: isGradientExpanded) { value in
                    if value {
                        isLanguageExpanded = false
                    }
                }
                
                CustomButton(title: "Change Password") {
                    showChangePasswordView.toggle()
                }
                .sheet(isPresented: $showChangePasswordView) {
                    ChangePasswordView()
                }
                
                
                Text("App Version: \(settingsViewModel.appVersion)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)
                
                Spacer()
                CustomButton(title: "Logout") {
                    showAlert = true
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
