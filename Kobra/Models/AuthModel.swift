//
//  AuthModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/16/23.
//

struct AuthModel:Codable {
    let username: String
    let email: String
    let password: String
    
    init(username: String = "", email: String, password: String){
        self.username = username
        self.email = email
        self.password = password
    }
    
}
