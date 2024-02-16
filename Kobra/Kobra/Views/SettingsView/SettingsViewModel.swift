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
    @AppStorage("gradientIndex") public var gradientIndex: Int = 0
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("selectedLanguage") var selectedLanguage: String = "English"
    @AppStorage("pushNotificationsEnabled") var pushNotificationsEnabled: Bool = false
    // Here you can keep appVersion as @Published if it's something dynamic that you fetch from some server.
    // But if it's a static value that doesn't change during app runtime, you could just declare it as a let constant.
    @Published var appVersion: String = "Beta"
    
    let languages: [String] = ["English", "Spanish", "French", "German"] // Just for example
    
    func updateSelectedGradient(to newIndex: Int) {
        gradientIndex = newIndex
    }
    
    func updateSelectedLanguage(to newIndex: Int) {
        selectedLanguage = languages[newIndex]
    }
    
    func resetData() {
        gradientIndex = 0
        isDarkMode = false
        selectedLanguage = "English"
        pushNotificationsEnabled = false
        // Don't reset appVersion as it's not user-specific
    }
}
