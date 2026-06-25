import Foundation

public struct Notification: Hashable, Sendable, Identifiable {
    public var id: String { "notification:" + data.id }
    public let data: Data
    public let actor: User
    //public let timeAgo: String // exists in API; format on demand from data.createdAt

    public init(
        data: Data,
        actor: User,
    ) {
        self.data = data
        self.actor = actor
    }
}

public extension Notification {
    struct Data: Hashable, Sendable, Identifiable {
        public let id: String
        public let type: String
        public let message: String
        public let read: Bool
        public let relatedId: String
        public let targetUrl: String
        public let createdAt: Date

        public init(
            id: String,
            type: String,
            message: String,
            read: Bool,
            relatedId: String,
            targetUrl: String,
            createdAt: Date,
        ) {
            self.id = id
            self.type = type
            self.message = message
            self.read = read
            self.relatedId = relatedId
            self.targetUrl = targetUrl
            self.createdAt = createdAt
        }
    }
}

extension Notification {
    struct CodingData: Decodable {
        let notification: Data.CodingData
        let actor: User.CodingData
        //let time_ago: String // not needed because it is formatted on demand from created_at
    }
}

extension Notification.Data {
    struct CodingData: Decodable {
        let uid: String
        let type: String
        let message: String
        let read: Bool
        let related_uid: String
        let target_url: String
        let created_at: Date
    }
}

extension Notification.CodingData {
    var decoded: Notification {
        .init(
            data: notification.decoded,
            actor: actor.decoded,
        )
    }
}

extension Notification.Data.CodingData {
    var decoded: Notification.Data {
        .init(
            id: uid,
            type: type,
            message: message,
            read: read,
            relatedId: related_uid,
            targetUrl: target_url,
            createdAt: created_at,
        )
    }
}
