//
//  MarketPlaceView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/26/23.
//
import Foundation
import SwiftUI

struct SettingsView: View {
    @State private var isExpanded = false
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    var body: some View {
        VStack{
            Text("Background Gradient")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .padding(.bottom, 10)

            DropDownMenu(
                isExpanded: $isExpanded,
                options: gradientOptions.indices.map { "Gradient \($0 + 1)" },
                selection: .constant("Gradient \(settingsViewModel.gradientIndex + 1)"),
                onOptionSelected: { index in
                    settingsViewModel.updateSelectedGradient(to: index)
                }
            )
            Spacer()
        }
        .padding()
    }
}
