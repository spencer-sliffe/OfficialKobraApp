//
import Firebase

class AccountViewModel: ObservableObject {
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil
    }
}
