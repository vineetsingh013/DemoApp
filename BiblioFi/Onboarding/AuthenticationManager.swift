import FirebaseAuth
import FirebaseFirestore

class AuthenticationManager {
    static let shared = AuthenticationManager()
    private let db = Firestore.firestore()

    private init() {}

    func createUser(email: String, password: String, firstName: String, lastName: String, phoneNumber: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else {
                print("User object is nil after creation")
                return
            }
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            // Store additional user data in Firestore
            self.db.collection("users").document(user.uid).setData([
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "phoneNumber": phoneNumber,
                "uid": user.uid
            ]) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                    // Handle error saving data if necessary
                } else {
                    // Data saved successfully
                    print("User data saved successfully")
                }
            }
        }
    }

    func logoutUser() throws {
        try Auth.auth().signOut()
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
    
        func loginUser(email: String, password: String) async throws -> User {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
//            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            return authResult.user
        }
}
