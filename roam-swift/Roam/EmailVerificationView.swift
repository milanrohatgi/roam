import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var verificationCode = ""
    @State private var email: String
    
    init(email: String) {
        self._email = State(initialValue: email)
    }
    
    var body: some View {
        VStack {
            Text("Enter the verification code sent to your email")
                .padding()
            
            TextField("Verification Code", text: $verificationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()
            
            Button("Verify") {
                authViewModel.verifyEmail(email: email, code: verificationCode)
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
        .navigationTitle("Email Verification")
    }
}
