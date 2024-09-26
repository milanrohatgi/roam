import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var showingResetPassword = false
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
            
            Button("Send Reset Instructions") {
                authViewModel.forgotPassword(email: email)
            }
            .padding()
            
            if let message = authViewModel.message {
                Text(message)
                    .foregroundColor(.green)
                    .padding()
            }
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Forgot Password")
        .alert(isPresented: $showingResetPassword) {
            Alert(
                title: Text("Reset Password"),
                message: Text("Please check your email for instructions to reset your password."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: authViewModel.message) { message in
            if message?.contains("Password reset instructions sent") ?? false {
                showingResetPassword = true
            }
        }
    }
}
