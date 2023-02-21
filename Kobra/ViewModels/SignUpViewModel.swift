//
//  SignUpViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/15/23.
//
import Foundation
import Combine
class SignUpViewModel: ObservableObject{
    private var cancellableBag = Set<AnyCancellable>()
    
    @Published  var name: String = ""
    var nameError: String = ""
    @Published var username: String = ""
    var usernameError: String = ""
    @Published var email: String = ""
    var emailError: String = ""
    @Published var password: String = ""
    var passwordError: String = ""
    @Published var confirmPassword: String = ""
    var confirmPasswordError: String = ""
    @Published var phone: String = ""
    var phoneError: String = ""
    
    private var usernameValidPublisher: AnyPublisher<Bool, Never> {
        return $username
            .map {!$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var nameValidPublisher: AnyPublisher<Bool, Never> {
        return $name
            .map {!$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
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
    
    private var phoneRequiredPublisher: AnyPublisher<(phone: String, isValid: Bool), Never> {
        return $phone
            .map {(phone: $0 , isValid: !$0.isEmpty)}
            .eraseToAnyPublisher()
    }
    
    private var phoneValidPublisher: AnyPublisher<Bool, Never> {
        return phoneRequiredPublisher
            .filter{ $0.isValid}
            .map { $0.phone.isValidPhone()  }
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
    
    private var confirmPasswordRequiredPublisher: AnyPublisher<(password: String, isValid: Bool), Never> {
        return $confirmPassword
            .map { (password: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }
    
    private var passwordEqualPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($password, $confirmPassword)
            .filter{ !$0.0.isEmpty && !$0.1.isEmpty}
            .map { password, confirm in
                return password == confirm
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        nameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0 ? "" : "Name is Required"}
            .assign(to: \.nameError, on: self)
            .store(in: &cancellableBag)
        usernameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0 ? "" : "Username is Required"}
            .assign(to: \.usernameError, on: self)
            .store(in: &cancellableBag)
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
        phoneRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Phone Number is Required"}
            .assign(to: \.phoneError, on: self)
            .store(in: &cancellableBag)
        phoneValidPublisher
            .receive(on: RunLoop.main)
            .map { $0 ? "" : "Phone Number is not Valid"}
            .assign(to: \.phoneError, on: self)
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
        passwordRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Confirm Password Please"}
            .assign(to: \.confirmPasswordError, on: self)
            .store(in: &cancellableBag)
        passwordEqualPublisher
            .receive(on: RunLoop.main)
            .map { $0 ? "" : "Passwords do not Match"}
            .assign(to: \.confirmPasswordError, on: self)
            .store(in: &cancellableBag)
    }
    
    deinit {
        cancellableBag.removeAll()
    }
}
extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidPassword(pattern: String = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$") -> Bool {
        let passwordRegEx = pattern
        return NSPredicate(format:"SELF MATCHES %@", passwordRegEx).evaluate(with: self)
    }
    
    func isValidPhone(pattern: String = "^\\d{3}-\\d{3}-\\d{4}$") -> Bool {
        let phoneRegEx = pattern
        return NSPredicate(format:"SELF MATCHES %@", phoneRegEx).evaluate(with: self)
    }
}
