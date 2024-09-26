import Foundation

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isVerified = false
    @Published var message: String?
    private let baseURL = "http://localhost:3000/api"
    
    func register(email: String, password: String, name: String) {
        guard let url = URL(string: "\(baseURL)/users/register") else {
            errorMessage = "Invalid URL"
            return
        }
        
        let body: [String: String] = ["email": email, "password": password, "name": name]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Registration failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)
                    if let message = decodedResponse["message"] {
                        self.message = message
                    } else {
                        self.errorMessage = "Unexpected response from server"
                    }
                } catch {
                    self.errorMessage = "Registration failed: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func verifyEmail(email: String, code: String) {
        guard let url = URL(string: "\(baseURL)/users/verify") else {
            errorMessage = "Invalid URL"
            return
        }
        
        let body: [String: String] = ["email": email, "verificationCode": code]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Verification failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)
                    if let message = decodedResponse["message"] {
                        self.message = message
                        self.isVerified = true
                    } else {
                        self.errorMessage = "Unexpected response from server"
                    }
                } catch {
                    self.errorMessage = "Verification failed: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func login(email: String, password: String) {
        guard let url = URL(string: "\(baseURL)/users/login") else {
            errorMessage = "Invalid URL"
            return
        }
        
        let body: [String: String] = ["email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)
                    if let token = decodedResponse["token"] {
                        UserDefaults.standard.set(token, forKey: "authToken")
                        self.isAuthenticated = true
                    } else if let error = decodedResponse["error"] {
                        self.errorMessage = error
                    } else {
                        self.errorMessage = "Unexpected response from server"
                    }
                } catch {
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        isAuthenticated = false
    }
    
    func forgotPassword(email: String) {
        guard let url = URL(string: "\(baseURL)/users/forgot-password") else {
            errorMessage = "Invalid URL"
            return
        }
        
        let body: [String: String] = ["email": email]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to send reset instructions: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)
                    if let message = decodedResponse["message"] {
                        self.message = message
                    } else {
                        self.errorMessage = "Unexpected response from server"
                    }
                } catch {
                    self.errorMessage = "Failed to send reset instructions: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func resetPassword(email: String, resetCode: String, newPassword: String) {
        guard let url = URL(string: "\(baseURL)/users/reset-password") else {
            errorMessage = "Invalid URL"
            return
        }
        
        let body: [String: String] = ["email": email, "resetCode": resetCode, "newPassword": newPassword]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Password reset failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)
                    if let message = decodedResponse["message"] {
                        self.message = message
                    } else {
                        self.errorMessage = "Unexpected response from server"
                    }
                } catch {
                    self.errorMessage = "Password reset failed: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
