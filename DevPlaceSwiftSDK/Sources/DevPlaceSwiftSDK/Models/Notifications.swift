import Foundation

public struct Notifications: Hashable, Sendable {
    public let groups: [NotificationGroup]
    public let nextCursor: Date?

    public init(
        groups: [NotificationGroup],
        nextCursor: Date?,
    ) {
        self.groups = groups
        self.nextCursor = nextCursor
    }
}

extension Notifications {
    struct CodingData: Decodable {
        let notification_groups: [NotificationGroup.CodingData]
        let next_cursor: Date?
    }
}

extension Notifications.CodingData {
    var decoded: Notifications {
        .init(
            groups: notification_groups.map(\.decoded),
            nextCursor: next_cursor,
        )
    }
}
