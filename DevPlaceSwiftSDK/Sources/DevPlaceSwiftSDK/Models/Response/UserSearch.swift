public struct UserSearch: Hashable, Sendable {
    public let results: [Result]

    public init(
        results: [Result],
    ) {
        self.results = results
    }
}

public extension UserSearch {
    struct Result: Hashable, Sendable, Identifiable {
        public let id: String
        public let username: String
        public let avatarSeed: String?

        public init(
            id: String,
            username: String,
            avatarSeed: String?,
        ) {
            self.id = id
            self.username = username
            self.avatarSeed = avatarSeed
        }
    }
}

extension UserSearch {
    struct CodingData: Decodable {
        let results: [Result.CodingData]
    }
}

extension UserSearch.Result {
    struct CodingData: Decodable {
        let uid: String
        let username: String
        let avatar_seed: String?
    }
}

extension UserSearch.CodingData {
    var decoded: UserSearch {
        .init(
            results: results.map(\.decoded),
        )
    }
}

extension UserSearch.Result.CodingData {
    var decoded: UserSearch.Result {
        .init(
            id: uid,
            username: username,
            avatarSeed: avatar_seed,
        )
    }
}
