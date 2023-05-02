//
//  SettingsViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/2/23.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("gradientIndex") public var gradientIndex: Int = 0
    var selectedGradient: (Color, Color) {
        gradientOptions[gradientIndex]
    }
    func updateSelectedGradient(to newIndex: Int) {
        gradientIndex = newIndex
    }

}
