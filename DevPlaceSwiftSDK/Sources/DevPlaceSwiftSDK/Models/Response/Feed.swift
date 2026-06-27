import Foundation

public struct Feed: Hashable, Sendable {
    public let posts: [Post]
    public let currentTab: String
    public let currentTopic: String?
    public let search: String
    public let nextCursor: Date?
    public let totalMembers: Int
    public let postsToday: Int
    public let totalProjects: Int
    public let totalGists: Int
    public let topAuthors: [User]
    //public let dailyTopic: ??? // null in sample - type unknown

    public init(
        posts: [Post],
        currentTab: String,
        currentTopic: String?,
        search: String,
        nextCursor: Date?,
        totalMembers: Int,
        postsToday: Int,
        totalProjects: Int,
        totalGists: Int,
        topAuthors: [User],
    ) {
        self.posts = posts
        self.currentTab = currentTab
        self.currentTopic = currentTopic
        self.search = search
        self.nextCursor = nextCursor
        self.totalMembers = totalMembers
        self.postsToday = postsToday
        self.totalProjects = totalProjects
        self.totalGists = totalGists
        self.topAuthors = topAuthors
    }
}

extension Feed {
    struct CodingData: Decodable {
        let posts: [Post.CodingData]
        let current_tab: String
        let current_topic: String?
        let search: String
        let next_cursor: Date?
        let total_members: Int
        let posts_today: Int
        let total_projects: Int
        let total_gists: Int
        let top_authors: [User.CodingData]
        //let daily_topic: ??? // null in sample - type unknown
    }
}

extension Feed.CodingData {
    var decoded: Feed {
        .init(
            posts: posts.map(\.decoded),
            currentTab: current_tab,
            currentTopic: current_topic,
            search: search,
            nextCursor: next_cursor,
            totalMembers: total_members,
            postsToday: posts_today,
            totalProjects: total_projects,
            totalGists: total_gists,
            topAuthors: top_authors.map(\.decoded),
        )
    }
}
