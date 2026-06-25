public struct NotificationGroup: Hashable, Sendable {
    public let label: String
    public let entries: [Notification]

    public init(
        label: String,
        entries: [Notification],
    ) {
        self.label = label
        self.entries = entries
    }
}

extension NotificationGroup {
    struct CodingData: Decodable {
        let label: String
        let entries: [Notification.CodingData]
    }
}

extension NotificationGroup.CodingData {
    var decoded: NotificationGroup {
        .init(
            label: label,
            entries: entries.map(\.decoded),
        )
    }
}
