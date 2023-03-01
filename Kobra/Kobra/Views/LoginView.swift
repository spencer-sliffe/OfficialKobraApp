//
//  LoginView.swift
//  Kobra
//
//  Created by Saje on 2/28/23.
//
import SwiftUI
import Firebase

struct LoginView: View {
    
    @ObservedObject private var viewModel : LoginViewModel
    @State private var userIsLoggedIn : Bool = false
    
    init(viewModel: LoginViewModel){
        self.viewModel = viewModel
    }
    
    var body: some View {
        if userIsLoggedIn {
            HomePageView()
        }
        else {
            content
        }
    }
    
    var content: some View {
        ZStack{
            ColorCodes.primary.loginColor().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Sign In")
                    .font(Font
                        .custom("Exo-VariableFont_wght.ttf", size: 35))
                    .foregroundColor(Color.white)
                    .padding(.bottom, 20.0)
                    .multilineTextAlignment(.center)
                
                LoginAuthTextField(title: "Email", textValue: $viewModel.email, errorValue: viewModel.emailError, keyboardType: .emailAddress )
                LoginAuthTextField(title: "Password", textValue: $viewModel.password, errorValue: viewModel.passwordError , isSecured: true)
                Button(action: viewModel.Login){
                    Text("Sign In")
                }.frame(minWidth: 0.0, maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(.infinity)
                HStack{
                    Text("Don't have an account? Sign Up")
                }
            }
            .padding(60.0)
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        userIsLoggedIn.toggle()
                    }
                }
            }
        }
    }
}
struct LoginContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LoginViewModel()
        LoginView(viewModel: viewModel)
    }
}
struct LoginAuthTextField: View{
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
                    .background(ColorCodes.background.loginColor())
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .cornerRadius(5.0)
                    .keyboardType(keyboardType)
            }else{
                TextField(title, text: $textValue)
                    .textFieldStyle(.roundedBorder)
                    .background(ColorCodes.background.loginColor())
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .keyboardType(keyboardType)
                    .cornerRadius(5.0)
            }
            Text(errorValue)
                .fontWeight(.light)
                .foregroundColor(ColorCodes.failure.loginColor())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
        }
    }
}
extension ColorCodes{
    func loginColor() -> Color{
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
