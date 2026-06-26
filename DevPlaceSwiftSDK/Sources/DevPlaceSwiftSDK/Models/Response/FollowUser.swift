public struct FollowUser: Hashable, Sendable, Identifiable {
    public let id: String
    public let username: String
    public let bio: String
    public let isFollowing: Bool

    public init(
        id: String,
        username: String,
        bio: String,
        isFollowing: Bool,
    ) {
        self.id = id
        self.username = username
        self.bio = bio
        self.isFollowing = isFollowing
    }
}

extension FollowUser {
    struct CodingData: Decodable {
        let uid: String
        let username: String
        let bio: String
        let is_following: Bool
    }
}

extension FollowUser.CodingData {
    var decoded: FollowUser {
        .init(
            id: uid,
            username: username,
            bio: bio,
            isFollowing: is_following,
        )
    }
}
