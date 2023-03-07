import SwiftUI
import Firebase

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        ZStack {
            if !viewModel.isSignedIn {
               AuthenticationView()
            } else {
                VStack(spacing: 20) {
                    Text("Sign Out")
                        .font(.custom("Exo-VariableFont_wght.ttf", size: 35))
                        .foregroundColor(.white)
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(.infinity)
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(viewModel: AccountViewModel(isPresented: .constant(false)))
    }
}
