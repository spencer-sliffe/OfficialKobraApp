//
//  SignUpView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 2/7/23.
//
import SwiftUI
struct SignUpView: View {
    
    @ObservedObject private var viewModel : SignUpViewModel
    
    init(viewModel: SignUpViewModel){
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack{
            ColorCodes.primary.color().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Create Account")
                    .font(Font
                        .custom("Exo-VariableFont_wght.ttf", size: 35))
                    .foregroundColor(Color.white)
                    .padding(.bottom, 20.0)
                    .multilineTextAlignment(.center)
                
                AuthTextField(title: "Email", textValue: $viewModel.email, errorValue: viewModel.emailError, keyboardType: .emailAddress )
                AuthTextField(title: "Username", textValue: $viewModel.username, errorValue: viewModel.usernameError )
                AuthTextField(title: "Password", textValue: $viewModel.password, errorValue: viewModel.passwordError , isSecured: true)
                AuthTextField(title: "Confirm Password", textValue: $viewModel.confirmPassword, errorValue: viewModel.confirmPasswordError , isSecured: true)
                Button(action: signUp) {
                    Text("Sign Up")
                }
                .disabled(!viewModel.enableSignUp)
                    .frame(minWidth: 0.0, maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(.infinity)
                
            }.padding(60.0)
        }
    }
    
    func signUp() -> Void{
        print("Sign Up Clicked!")
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SignUpViewModel(authApi: AuthService.shared, authServiceParser: AuthServiceParser.shared)
        SignUpView(viewModel: viewModel)
    }
}
struct AuthTextField: View{
    var title: String
    @Binding var textValue: String
    var errorValue: String
    var isSecured: Bool = false
    var keyboardType: UIKeyboardType = .default
    var body: some View{
        VStack{
            if isSecured{
                SecureField(title, text: $textValue)
                    .textFieldStyle(.roundedBorder)
                    .background(ColorCodes.background.color())
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .cornerRadius(5.0)
                    .keyboardType(keyboardType)
            }else{
                TextField(title, text: $textValue)
                    .textFieldStyle(.roundedBorder)
                    .background(ColorCodes.background.color())
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .keyboardType(keyboardType)
                    .cornerRadius(5.0)
            }
            Text(errorValue)
                .fontWeight(.light)
                .foregroundColor(ColorCodes.failure.color())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
        }
    }
}
extension ColorCodes{
    func color() -> Color{
        switch self{
        case .primary:
            return Color(red: 82/255,
                         green: 55/255,
                         blue: 131/255)
        case .success:
            return Color(red: 0,
                         green: 0,
                         blue: 0)
        case .failure:
            return Color(red: 219/255,
                         green: 12/255,
                         blue: 12/255)
        case .background:
            return Color(red: 239/255,
                         green: 243/255,
                         blue: 244/255,
                         opacity: 1)
        }
    }
}
