import SwiftUI
import Firebase

struct AuthenticationView: View {
    @StateObject var authViewModel = AuthenticationViewModel()
    @State private var selection = 0
    @State private var signInSuccess = false
    @State private var isNavigating = false
    @State private var isPresented = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    Image("kobracoding-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: UIScreen.main.bounds.height * 0.25)
                        .padding(.top, UIScreen.main.bounds.height * 0.13)
                    
                    VStack {
                        Picker(selection: $selection, label: Text("Sign In or Sign Up")) {
                            Text("Sign In").tag(0)
                                .font(.system(size: 18 * 3))
                            Text("Sign Up").tag(1)
                                .font(.system(size: 18 * 3))
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 30)
                        .background(Color.clear)
                        .cornerRadius(10)
                        .foregroundColor(.blue)
                        .accentColor(.blue)
                        .frame(height: 50)
                        .padding(.horizontal, 20)
                        
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
                        
                        if selection == 1 {
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
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                                .font(.system(size: 20))
                        }
                        .disabled(authViewModel.isLoading)
                        .opacity(authViewModel.isLoading ? 0.5 : 1)
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
                .background(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .navigationBarHidden(true)
            .onReceive(authViewModel.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    signInSuccess = true // present the account view when the user is authenticated
                }
            }
            .fullScreenCover(isPresented: $signInSuccess) {
                HomePageView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            }
        } .navigationBarHidden(true)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        return AuthenticationView()
    }
}
