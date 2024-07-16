import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginPage: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var shouldNavigate: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isEmailValid: Bool = false
    @State private var isCheckingEmail: Bool = false

    @State private var emailError: String = ""
    @State private var emailDebounceWorkItem: DispatchWorkItem?

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 10) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150) // Adjust size as needed

                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    Text("Please login to your account")
                        .font(.subheadline)
                        .padding(.bottom, 40)

                    VStack(alignment: .leading) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding(.horizontal, 20)
                            .onChange(of: email) { _, _ in
                                debounceEmailValidation()
                            }

                        if !emailError.isEmpty {
                            Text(emailError)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.leading, 20)
                        }
                    }

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)

                    HStack {
                        Spacer()
                        NavigationLink(destination: ResetPasswordView().navigationBarBackButtonHidden(true)) {
                            Text("Forgot password?")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                        .padding(.trailing, 20)
                    }

                    Button(action: {
                        loginUser()
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#945200"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .disabled(email.isEmpty || password.isEmpty)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }

                    NavigationLink(destination: NewSwift().navigationBarBackButtonHidden(true), isActive: $shouldNavigate) {
                        EmptyView()
                    }
                    .hidden()

                    NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true)) {
                        Text("Don't have an account? Signup")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 0)

                    Spacer()
                }
                .padding()
            }
        }
        .onChange(of: isLoggedIn) { newValue in
            if newValue {
                // Navigate to HomeView if isLoggedIn is true
                shouldNavigate = true
            }
        }
        .onAppear {
            // Check login status on appearance
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
        .onDisappear {
            // Reset email and password fields when navigating away
            email = ""
            password = ""
        }
    }

    private func debounceEmailValidation() {
        emailDebounceWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            validateEmail()
        }
        emailDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
    }

    private func validateEmail() {
        emailError = ""
        isEmailValid = false

        if !isValidEmail(email) {
            emailError = "Invalid email format"
            return
        }

        // Simulated validation logic
        self.isEmailValid = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email) && !email.contains("...")
    }

    private func loginUser() {
        validateEmail()

        if emailError.isEmpty {
            // Simulated login for demonstration purposes
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Failed to sign in: \(error.localizedDescription)")
                    self.alertMessage = "Email or password is incorrect"
                    self.showAlert = true
                } else {
                    print("Successfully signed in user with uid: \(authResult?.user.uid ?? "Unknown")")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self.isLoggedIn = true // Update isLoggedIn state
                    self.shouldNavigate = true // Trigger navigation
                }
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}

