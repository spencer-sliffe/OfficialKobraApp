import SwiftUI
import Firebase

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel
    @State private var isPresented = false
    
    var body: some View {
        NavigationView {
            if !viewModel.isSignedIn {
               AuthenticationView()
            } else {
                ZStack {
                    VStack(spacing: 20) {
                        Text("Sign Out")
                            .font(.custom("Exo-VariableFont_wght.ttf", size: 35))
                            .foregroundColor(.white)
                        Button(action: {
                            viewModel.signOut()
                            isPresented.toggle()
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
                .navigationBarHidden(true)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(
            NavigationLink(
                destination: AuthenticationView(),
                isActive: $isPresented,
                label: {
                    EmptyView()
                }
            )
            .hidden()
        )
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(viewModel: AccountViewModel())
    }
}
