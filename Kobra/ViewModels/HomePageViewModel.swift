//
//  HomePageViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//

import Foundation

class HomePageViewModel: ObservableObject {
    @Published var accountIsActive = false
    @Published var packageIsActive = false
    
    func activateAccount() {
        accountIsActive = true
        packageIsActive = false
    }
    
    func activatePackage() {
        accountIsActive = false
        packageIsActive = true
    }
}
