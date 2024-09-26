import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var emailError = ""
    @State private var showingRegistration = false
    @State private var showingForgotPassword = false
    
    private func validateEmail() {
        if !email.lowercased().hasSuffix("@stanford.edu") {
            emailError = "Please use a valid Stanford email address"
        } else {
            emailError = ""
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .onChange(of: email) { _ in validateEmail() }
                
                if !emailError.isEmpty {
                    Text(emailError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    isLoggingIn = true
                    authViewModel.login(email: email, password: password)
                }) {
                    Text(isLoggingIn ? "Logging in..." : "Login")
                }
                .disabled(isLoggingIn || !emailError.isEmpty)
                .padding()
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button("Forgot Password?") {
                    showingForgotPassword = true
                }
                .padding()
                
                Button("Create Account") {
                    showingRegistration = true
                }
                .padding()
            }
            .padding()
            .navigationTitle("Login")
            .sheet(isPresented: $showingRegistration) {
                RegistrationView()
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}
