//
//  SettingsViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/2/23.
//

import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var selectedGradientIndex: Int = 0
}
