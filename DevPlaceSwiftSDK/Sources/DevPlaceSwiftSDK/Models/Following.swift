public struct Following: Hashable, Sendable {
    public let username: String
    public let mode: String
    public let count: Int
    public let page: Int
    public let totalPages: Int
    public let following: [FollowUser]

    public init(
        username: String,
        mode: String,
        count: Int,
        page: Int,
        totalPages: Int,
        following: [FollowUser],
    ) {
        self.username = username
        self.mode = mode
        self.count = count
        self.page = page
        self.totalPages = totalPages
        self.following = following
    }
}

extension Following {
    struct CodingData: Decodable {
        let username: String
        let mode: String
        let count: Int
        let page: Int
        let total_pages: Int
        let following: [FollowUser.CodingData]
    }
}

extension Following.CodingData {
    var decoded: Following {
        .init(
            username: username,
            mode: mode,
            count: count,
            page: page,
            totalPages: total_pages,
            following: following.map(\.decoded),
        )
    }
}
