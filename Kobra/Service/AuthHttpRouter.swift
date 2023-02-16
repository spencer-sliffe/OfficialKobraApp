//
//  AuthHttpRouter.swift
//  Kobra
//
//  Created by Spencer SLiffe on 2/16/23.
//

import Alamofire

enum AuthHttpRouter{
    case signUp(AuthModel)
    case validateEmail(email: String)
}

extension AuthHttpRouter: HttpRouter {
    
    var baseUrlString: String {
        return "https://kobracoding.com/"
    }
    
    var path: String{
        switch(self) {
        case .signUp:
            return "register"
        case .validateEmail:
            return "validate/email"
        }
    }
    
    var method: HTTPMethod {
        switch(self) {
        case .signUp, .validateEmail:
            return .post
        }
    }
    
    var headers: HTTPHeaders? {
        switch(self) {
        case .signUp, .validateEmail:
            return[
                "Content-Type": "application/json; charset=UTF-8"
            ]
        }
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    func body() throws -> Data? {
        switch self {
        case .signUp(let user):
            return try JSONEncoder().encode(user)
        case .validateEmail(let email):
            return try JSONEncoder().encode(["email" : email])
        }
    }
}
