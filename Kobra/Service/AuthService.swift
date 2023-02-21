//
//  AuthService.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/20/23.
//

import Foundation
import Combine


enum SignUpError : Error {
    case emailExists
    case invalidData
    case invalidJSON
    case error(error:String)
}

enum AuthResult<T> {
    case success(value: T)
    case failure(message: String)
}

class AuthService {
    lazy var httpService = AuthHttpService()
    static let shared : AuthService = AuthService()
    private init() {}
}

extension AuthService: AuthAPI {
    
    func signUp(username: String,
                email: String,
                password: String) -> Future<(statusCode: Int, data: Data), Error>{
        
        return Future<(statusCode: Int, data: Data), Error> { [httpService] promise in
            do {
                try AuthHttpRouter
                    .signUp(AuthModel(username: username, email: email, password: password))
                    .request(usingHttpService: httpService)
                    .responseJSON { (response) in
                        guard
                            let statusCode = response.response?.statusCode,
                            let data = response.data,
                            statusCode == 200 else {
                            promise(.failure(SignUpError.invalidData))
                            return
                        }
                        promise(.success((statusCode: statusCode, data: data)))
                    }
            } catch {
                print("Something went wrong: \(error)")
                promise(.failure(SignUpError.invalidData))
            }
        }
    }
    
    
    func checkEmail(email: String) -> Future<Bool, Never> {
        
        return Future<Bool, Never> { [httpService]
            promise in
            do {
                try AuthHttpRouter
                    .validateEmail(email: email)
                    .request(usingHttpService: httpService)
                    .responseJSON{ (response) in
                        guard response.response?.statusCode == 200 else {
                            promise(.success(false))
                            return
                        }
                        promise(.success(true))
                    }
            } catch {
                promise(.success(false))
            }
        }
    }
}
