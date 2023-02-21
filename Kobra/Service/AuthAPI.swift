//
//  AuthAPI.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/20/23.
//

import Foundation
import Combine

protocol AuthAPI {
    func signUp(username: String,
                email: String,
                password: String) -> Future<(statusCode: Int, data: Data), Error>
    func checkEmail(email: String) -> Future<Bool, Never>
    
}
