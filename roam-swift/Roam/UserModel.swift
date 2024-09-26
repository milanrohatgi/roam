import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let email: String
    let name: String
}
