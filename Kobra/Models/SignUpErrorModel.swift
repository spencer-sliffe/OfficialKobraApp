//
//  SignUpErrorModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/21/23.
//

import Foundation

struct SignUpErrorModel: Codable {
    let validationErrors: ValidationErrors
    
    enum codingKeys: String, CodingKey {
        case validationErrors = "validation_errors"
    }
}

struct ValidationErrors: Codable {
    let username, email, password: [String]?
}
