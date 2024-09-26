import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
        .alert(item: Binding<AlertItem?>(
            get: { authViewModel.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in authViewModel.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            MyRidesView()
                .tabItem {
                    Label("My Rides", systemImage: "car")
                }
            NewRideView()
                .tabItem {
                    Label("New", systemImage: "plus.circle.fill")
                }
            GroupsView()
                .tabItem {
                    Label("Groups", systemImage: "person.3")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
