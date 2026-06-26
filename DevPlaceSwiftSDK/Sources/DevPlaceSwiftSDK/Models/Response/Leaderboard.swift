public struct Leaderboard: Hashable, Sendable {
    public let entries: [LeaderboardEntry]
    public let userRank: Int
    public let totalMembers: Int
    public let postsToday: Int
    public let totalProjects: Int
    public let totalGists: Int
    public let topAuthors: [User]
    public let featuredNews: [Article.Data]

    public init(
        entries: [LeaderboardEntry],
        userRank: Int,
        totalMembers: Int,
        postsToday: Int,
        totalProjects: Int,
        totalGists: Int,
        topAuthors: [User],
        featuredNews: [Article.Data],
    ) {
        self.entries = entries
        self.userRank = userRank
        self.totalMembers = totalMembers
        self.postsToday = postsToday
        self.totalProjects = totalProjects
        self.totalGists = totalGists
        self.topAuthors = topAuthors
        self.featuredNews = featuredNews
    }
}

extension Leaderboard {
    struct CodingData: Decodable {
        let entries: [LeaderboardEntry.CodingData]
        let user_rank: Int
        let total_members: Int
        let posts_today: Int
        let total_projects: Int
        let total_gists: Int
        let top_authors: [User.CodingData]
        let featured_news: [Article.Data.CodingData]
    }
}

extension Leaderboard.CodingData {
    var decoded: Leaderboard {
        .init(
            entries: entries.map(\.decoded),
            userRank: user_rank,
            totalMembers: total_members,
            postsToday: posts_today,
            totalProjects: total_projects,
            totalGists: total_gists,
            topAuthors: top_authors.map(\.decoded),
            featuredNews: featured_news.map(\.decoded),
        )
    }
}
