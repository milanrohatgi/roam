import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
                
                // Add more sections and items for profile information and settings
                // For example:
                Section(header: Text("Personal Information")) {
                    Text("Name: John Doe")
                    Text("Email: john@stanford.edu")
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Notifications", isOn: .constant(true))
                    Toggle("Dark Mode", isOn: .constant(false))
                }
            }
            .navigationTitle("Profile")
        }
    }
}
