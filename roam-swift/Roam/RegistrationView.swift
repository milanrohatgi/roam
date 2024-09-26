import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var emailError = ""
    @State private var isRegistering = false
    @Environment(\.presentationMode) var presentationMode
    
    private func validateEmail() {
        if !email.lowercased().hasSuffix("@stanford.edu") {
            emailError = "Please use a valid Stanford email address"
        } else {
            emailError = ""
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .onChange(of: email) { _ in validateEmail() }
                    if !emailError.isEmpty {
                        Text(emailError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section(header: Text("Password")) {
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                Section {
                    Button(action: {
                        if password == confirmPassword {
                            isRegistering = true
                            authViewModel.register(email: email, password: password, name: name)
                        }
                    }) {
                        if isRegistering {
                            ProgressView()
                        } else {
                            Text("Register")
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || name.isEmpty || password != confirmPassword || !emailError.isEmpty || isRegistering)
                }
            }
            .navigationTitle("Registration")
            .onChange(of: authViewModel.message) { message in
                if message?.contains("User registered") ?? false {
                    isRegistering = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .onChange(of: authViewModel.errorMessage) { error in
                if error != nil {
                    isRegistering = false
                }
            }
        }
    }
}
