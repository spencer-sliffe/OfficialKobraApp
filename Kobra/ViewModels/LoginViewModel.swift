//
//  LoginViewModel.swift
//  Kobra
//
//  Created by Saje on 2/28/23.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject{
    private var cancellableBag = Set<AnyCancellable>()
    
    @Published var email: String = ""
    var emailError: String = ""
    @Published var password: String = ""
    var passwordError: String = ""
    
    private var emailRequiredPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        return $email
            .map {(email: $0 , isValid: !$0.isEmpty)}
            .eraseToAnyPublisher()
    }
    
    private var emailValidPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        return emailRequiredPublisher
            .filter{ $0.isValid}
            .map { (email: $0.email, isValid: $0.email.isValidEmail()) }
            .eraseToAnyPublisher()
    }
    private var passwordRequiredPublisher: AnyPublisher<(password: String, isValid: Bool), Never> {
        return $password
            .map { (password: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }
    
    private var passwordValidPublisher: AnyPublisher<Bool, Never> {
        return passwordRequiredPublisher
            .filter{ $0.isValid }
            .map { $0.password.isValidPassword() }
            .eraseToAnyPublisher()
    }
    
    init() {
        emailRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Email is Required"}
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        emailValidPublisher
            .receive(on: RunLoop.main)
            .map { $0.isValid ? "" : "Email is not Valid"}
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        passwordRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Password is Required"}
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellableBag)
        passwordValidPublisher
            .receive(on: RunLoop.main)
            .map { $0 ? "" : "Password is not Valid"}
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellableBag)

    }
    
    deinit {
        cancellableBag.removeAll()
    }
}
extension String {

    }
