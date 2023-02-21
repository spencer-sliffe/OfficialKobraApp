//
//  TokenResponseModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/21/23.
//

import Foundation

struct TokenResponseModel: Decodable {
    
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
