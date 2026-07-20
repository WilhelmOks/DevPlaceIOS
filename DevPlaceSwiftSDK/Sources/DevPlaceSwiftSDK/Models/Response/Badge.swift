import Foundation

public struct Badge: Hashable, Sendable {
    public let name: String?
    public let createdAt: Date

    public init(
        name: String?,
        createdAt: Date,
    ) {
        self.name = name
        self.createdAt = createdAt
    }
}

extension Badge {
    struct CodingData: Decodable {
        let name: String?
        let created_at: Date
    }
}

extension Badge.CodingData {
    var decoded: Badge {
        .init(
            name: name,
            createdAt: created_at,
        )
    }
}
