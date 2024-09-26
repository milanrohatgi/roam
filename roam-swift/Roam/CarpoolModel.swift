import Foundation
/*
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
        
        let dateString = try container.decode(String.self, forKey: .dateTime)
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            dateTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .dateTime, in: container, debugDescription: "Date string does not match expected format")
        }
    }
}
*/
