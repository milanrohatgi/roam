import Foundation

struct CarpoolRequest: Identifiable, Codable {
    let id: Int
    let userId: Int
    let groupId: Int
    let title: String
    let description: String
    let origin: String
    let destination: String
    let dateTime: Date
    let isAnonymous: Bool
    let status: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case groupId = "group_id"
        case title
        case description
        case origin
        case destination
        case dateTime = "date_time"
        case isAnonymous = "is_anonymous"
        case status
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        groupId = try container.decode(Int.self, forKey: .groupId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        origin = try container.decode(String.self, forKey: .origin)
        destination = try container.decode(String.self, forKey: .destination)
        isAnonymous = try container.decode(Bool.self, forKey: .isAnonymous)
        status = try container.decode(String.self, forKey: .status)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateTimeString = try container.decode(String.self, forKey: .dateTime)
        if let date = dateFormatter.date(from: dateTimeString) {
            dateTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .dateTime, in: container, debugDescription: "Date string does not match expected format")
        }
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date string does not match expected format")
        }
    }
}

class CarpoolViewModel: ObservableObject {
    @Published var carpools: [CarpoolRequest] = []
    @Published var errorMessage: String?
    private let baseURL = "http://localhost:3000/api"
    
    func fetchGroupCarpools() {
        guard let url = URL(string: "\(baseURL)/carpools/group-carpools") else {
            errorMessage = "Invalid URL"
            return
        }
        
        print("Fetching group carpools from URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue(token, forHTTPHeaderField: "x-auth-token")
            print("Using token: \(token)")
        } else {
            print("No authentication token found")
            DispatchQueue.main.async {
                self.errorMessage = "No authentication token found"
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response"
                }
                return
            }
            
            print("Received HTTP status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server error: HTTP \(httpResponse.statusCode)")
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("Response body: \(body)")
                }
                DispatchQueue.main.async {
                    self.errorMessage = "Server error: HTTP \(httpResponse.statusCode)"
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode([CarpoolRequest].self, from: data)
                print("Successfully decoded \(decodedResponse.count) carpools")
                DispatchQueue.main.async {
                    self.carpools = decodedResponse
                }
            } catch {
                print("Decoding error: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Received data: \(dataString)")
                }
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
