public struct LeaderboardEntry: Hashable, Sendable, Identifiable {
    public let id: String
    public let username: String
    public let avatarSeed: String?
    public let stars: Int
    public let level: Int
    public let rank: Int

    public init(
        id: String,
        username: String,
        avatarSeed: String?,
        stars: Int,
        level: Int,
        rank: Int,
    ) {
        self.id = id
        self.username = username
        self.avatarSeed = avatarSeed
        self.stars = stars
        self.level = level
        self.rank = rank
    }
}

extension LeaderboardEntry {
    struct CodingData: Decodable {
        let uid: String
        let username: String
        let avatar_seed: String?
        let stars: Int
        let level: Int
        let rank: Int
    }
}

extension LeaderboardEntry.CodingData {
    var decoded: LeaderboardEntry {
        .init(
            id: uid,
            username: username,
            avatarSeed: avatar_seed,
            stars: stars,
            level: level,
            rank: rank,
        )
    }
}
