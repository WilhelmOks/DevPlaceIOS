import Foundation

public struct Badge: Hashable, Sendable {
    public let name: String?
    public let icon: String?
    public let createdAt: Date

    public init(
        name: String?,
        icon: String?,
        createdAt: Date,
    ) {
        self.name = name
        self.icon = icon
        self.createdAt = createdAt
    }
}

extension Badge {
    struct CodingData: Decodable {
        let name: String?
        let icon: String?
        let created_at: Date
    }
}

extension Badge.CodingData {
    var decoded: Badge {
        .init(
            name: name,
            icon: icon,
            createdAt: created_at,
        )
    }
}
