public struct BookmarkItem: Hashable, Sendable, Identifiable {
    public var id: String { targetType + ":" + targetId }
    public let targetType: String
    public let targetId: String
    public let typeLabel: String
    public let title: String
    public let url: String
    //public let timeAgo: String // exists in API; format on demand from the target's createdAt

    public init(
        targetType: String,
        targetId: String,
        typeLabel: String,
        title: String,
        url: String,
    ) {
        self.targetType = targetType
        self.targetId = targetId
        self.typeLabel = typeLabel
        self.title = title
        self.url = url
    }
}

extension BookmarkItem {
    struct CodingData: Decodable {
        let target_type: String
        let target_uid: String
        let type_label: String
        let title: String
        let url: String
        //let time_ago: String // not needed because it is formatted on demand from created_at
    }
}

extension BookmarkItem.CodingData {
    var decoded: BookmarkItem {
        .init(
            targetType: target_type,
            targetId: target_uid,
            typeLabel: type_label,
            title: title,
            url: url,
        )
    }
}
