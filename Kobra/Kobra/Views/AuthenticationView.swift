//
// AuthenticationView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//

import SwiftUI
import Firebase

struct AuthenticationView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var selection = 0
    @State private var signInSuccess = false
    @State private var isNavigating = false
    @State private var isPresented = false
    @State private var showChangePasswordView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("kobracoding-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                    .padding(.top, UIScreen.main.bounds.height * 0.13)
                    .shadow(color: .black.opacity(1), radius: 2, x: 0, y: 0)
                VStack {
                    Picker(selection: $selection, label: Text("Sign In or Sign Up")) {
                        Text("Sign In").tag(0)
                            .font(.system(size: 18 * 3))
                        
                        Text("Sign Up").tag(1)
                            .font(.system(size: 18 * 3))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    if selection == 0 {
                        TextField("Email", text: $authViewModel.email)
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10)
                            .font(.system(size: 18))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        SecureField("Password", text: $authViewModel.password)
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10)
                            .font(.system(size: 18))
                        
                    } else if selection == 1 {
                        TextField("Email", text: $authViewModel.email)
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10)
                            .font(.system(size: 18))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        TextField("Username", text: $authViewModel.username)
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10)
                            .font(.system(size:18))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        SecureField("Password", text: $authViewModel.password)
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10)
                            .font(.system(size: 18))
                        
                        SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(10)
                            .font(.system(size: 18))
                    }
                    
                    if authViewModel.isError {
                        Text(authViewModel.errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        if selection == 0 {
                            authViewModel.signIn()
                        } else {
                            authViewModel.signUp()
                        }
                    }) {
                        Text(selection == 0 ? "Sign In" : "Sign Up")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 30)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                            .font(.system(size: 20))
                            .padding(.horizontal, 30)
                    }
                    .disabled(authViewModel.isLoading1)
                    .opacity(authViewModel.isLoading1 ? 0.5 : 1)
                    
                    if selection == 0 {
                        Button(action: {
                            showChangePasswordView.toggle()
                        }) {
                            Text("Forgot Password?")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .sheet(isPresented: $showChangePasswordView) {
                            ChangePasswordView()
                        }
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
            .onAppear {
                authViewModel.startListening()
            }
            .onDisappear {
                authViewModel.stopListening()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [.black, .black]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .navigationBarHidden(true)
    }
}

