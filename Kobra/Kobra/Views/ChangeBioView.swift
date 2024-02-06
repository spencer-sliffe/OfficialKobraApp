//
//  ChangeBioView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 1/24/24.
//

import Foundation
import SwiftUI

struct ChangeBioView: View {
    @Binding var bioInput: String
    @Binding var showChangeBioView: Bool // New binding
    @EnvironmentObject var viewModel: AccountViewModel // Inject AccountViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                CustomTextField(text: $bioInput, placeholder: "New Bio", characterLimit: 80)
                HStack {
                    CustomButton(title: "Save", action: {
                        // Save the new bio using updateBio function in AccountViewModel
                        viewModel.updateBio(bio: bioInput)
                        // Dismiss the ChangeBioView
                        showChangeBioView = false
                    })
                }
            }
            .padding(.top, 200)
        }
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        gradientOptions[settingsViewModel.gradientIndex].0,
                        gradientOptions[settingsViewModel.gradientIndex].1
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}


