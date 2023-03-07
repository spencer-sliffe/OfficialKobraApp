//
import Firebase
import SwiftUI

class AccountViewModel: ObservableObject {

    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isPresented = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil
    }
}
