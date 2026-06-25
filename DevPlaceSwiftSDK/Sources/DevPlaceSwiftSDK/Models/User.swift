import Foundation

public struct User: Hashable, Sendable, Identifiable {
    public let id: String
    public let username: String
    public let avatarSeed: String?
    public let role: String?
    public let bio: String
    public let location: String
    public let gitLink: String
    public let website: String
    public let level: Int
    public let xp: Int
    public let stars: Int
    public let createdAt: Date

    public init(
        id: String,
        username: String,
        avatarSeed: String?,
        role: String? = nil,
        bio: String,
        location: String,
        gitLink: String,
        website: String,
        level: Int,
        xp: Int,
        stars: Int,
        createdAt: Date,
    ) {
        self.id = id
        self.username = username
        self.avatarSeed = avatarSeed
        self.role = role
        self.bio = bio
        self.location = location
        self.gitLink = gitLink
        self.website = website
        self.level = level
        self.xp = xp
        self.stars = stars
        self.createdAt = createdAt
    }
}

extension User {
    struct CodingData: Decodable {
        let uid: String
        let username: String
        let avatar_seed: String?
        let role: String?
        let bio: String
        let location: String
        let git_link: String
        let website: String
        let level: Int
        let xp: Int
        let stars: Int
        let created_at: Date
    }
}

extension User.CodingData {
    var decoded: User {
        .init(
            id: uid,
            username: username,
            avatarSeed: avatar_seed,
            role: role,
            bio: bio,
            location: location,
            gitLink: git_link,
            website: website,
            level: level,
            xp: xp,
            stars: stars,
            createdAt: created_at,
        )
    }
}
