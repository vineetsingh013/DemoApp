import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ResetPasswordView: View {
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var shouldNavigateToLogin: Bool = false
    @State private var isTyping: Bool = false
    @State private var isEmailValid: Bool = false
    @State private var emailWarning: String? = nil
    
    // State property for debounce
    @State private var debounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Enter your email address to reset your password")
                    .font(.subheadline)
                    .padding(.bottom, 40)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal, 20)
                    .onChange(of: email) { newValue in
                        self.isTyping = true
                        debounceValidation()
                    }
                
                if let warning = emailWarning {
                    Text(warning)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal, 20)
                }
                
                Button(action: {
                    // Handle reset password action
                    resetPassword()
                }) {
                    Text("Reset Password")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#945200"))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .disabled(email.isEmpty || !isEmailValid || isTyping)
            }
            .padding()
            .navigationBarTitle("Forgot Password", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Reset Password"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            // Additional setup on view appear if needed
        }
    }
    
    private func debounceValidation() {
        debounceWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            self.validateEmail()
        }
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
    }
    
    private func validateEmail() {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}(|edu.in)$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let allowedDomains = ["gmail.com", "yahoo.com", "outlook.com", "icloud.com", "hotmail.com", "aol.com"]
        
        if email.isEmpty {
            emailWarning = nil
            isEmailValid = false
            return
        }
        
        if !emailPredicate.evaluate(with: email) {
            emailWarning = "Invalid email format"
            isEmailValid = false
            return
        }
        
        if let domain = email.split(separator: "@").last, !allowedDomains.contains(String(domain)) {
            emailWarning = "Email must be from a valid provider"
            isEmailValid = false
            return
        }
        
        // Check if email exists in users collection
        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                self.emailWarning = "Error checking email: \(error.localizedDescription)"
                self.isEmailValid = false
                return
            }
            
            if snapshot?.isEmpty == false {
                // Email exists in users collection
                self.emailWarning = nil
                self.isEmailValid = true
            } else {
                self.emailWarning = "Email not found"
                self.isEmailValid = false
            }
        }
        
        self.isTyping = false
    }
    
    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.alertMessage = "Error resetting password: \(error.localizedDescription)"
            } else {
                self.alertMessage = "A password reset email has been sent to \(self.email)."
                self.shouldNavigateToLogin = true
            }
            self.showAlert = true
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
