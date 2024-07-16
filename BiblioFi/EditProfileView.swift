import SwiftUI
import Firebase

struct EditProfileView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var showConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Edit Details")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Form {
                Section(header: Text("First Name")) {
                    TextField("First Name", text: $firstName)
                }

                Section(header: Text("Last Name")) {
                    TextField("Last Name", text: $lastName)
                }

                Section(header: Text("Phone Number")) {
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
            }

            Button(action: {
                // Save changes
                updateProfile()
            }) {
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#945200"))
                    .cornerRadius(8)
                    .padding()
            }
            .alert(isPresented: $showConfirmation) {
                Alert(
                    title: Text("Profile Updated"),
                    message: Text("Your profile has been successfully updated."),
                    dismissButton: .default(Text("OK")) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            Spacer()
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            fetchUserData()
        }
    }

    private func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently logged in.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let userData = document.data()
                firstName = userData?["firstName"] as? String ?? ""
                lastName = userData?["lastName"] as? String ?? ""
                phoneNumber = userData?["phoneNumber"] as? String ?? ""
            } else {
                print("Document does not exist")
            }
        }
    }

    private func updateProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently logged in.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)

        userRef.setData(["firstName": firstName, "lastName": lastName, "phoneNumber": phoneNumber], merge: true) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully.")
                showConfirmation = true
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
