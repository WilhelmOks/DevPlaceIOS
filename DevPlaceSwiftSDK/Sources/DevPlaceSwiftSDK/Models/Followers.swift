public struct Followers: Hashable, Sendable {
    public let username: String
    public let mode: String
    public let count: Int
    public let page: Int
    public let totalPages: Int
    public let followers: [FollowUser]

    public init(
        username: String,
        mode: String,
        count: Int,
        page: Int,
        totalPages: Int,
        followers: [FollowUser],
    ) {
        self.username = username
        self.mode = mode
        self.count = count
        self.page = page
        self.totalPages = totalPages
        self.followers = followers
    }
}

extension Followers {
    struct CodingData: Decodable {
        let username: String
        let mode: String
        let count: Int
        let page: Int
        let total_pages: Int
        let followers: [FollowUser.CodingData]
    }
}

extension Followers.CodingData {
    var decoded: Followers {
        .init(
            username: username,
            mode: mode,
            count: count,
            page: page,
            totalPages: total_pages,
            followers: followers.map(\.decoded),
        )
    }
}
