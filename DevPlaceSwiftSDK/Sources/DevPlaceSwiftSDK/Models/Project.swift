import Foundation

public struct Project: Hashable, Sendable, Identifiable {
    public var id: String { "project:" + uid }
    public let uid: String
    public let slug: String
    public let userId: String
    public let title: String
    public let description: String
    public let projectType: String
    public let status: String
    public let stars: Int
    public let isPrivate: Bool
    public let readOnly: Bool
    public let releaseDate: String
    public let demoDate: String
    public let createdAt: Date
    public let updatedAt: Date
    public let authorName: String
    public let myVote: Int
    public let recentComments: [Comment]
    //public let platforms: ??? // null in sample - type unknown

    public init(
        uid: String,
        slug: String,
        userId: String,
        title: String,
        description: String,
        projectType: String,
        status: String,
        stars: Int,
        isPrivate: Bool,
        readOnly: Bool,
        releaseDate: String,
        demoDate: String,
        createdAt: Date,
        updatedAt: Date,
        authorName: String,
        myVote: Int,
        recentComments: [Comment],
    ) {
        self.uid = uid
        self.slug = slug
        self.userId = userId
        self.title = title
        self.description = description
        self.projectType = projectType
        self.status = status
        self.stars = stars
        self.isPrivate = isPrivate
        self.readOnly = readOnly
        self.releaseDate = releaseDate
        self.demoDate = demoDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.authorName = authorName
        self.myVote = myVote
        self.recentComments = recentComments
    }
}

extension Project {
    struct CodingData: Decodable {
        let uid: String
        let slug: String
        let user_uid: String
        let title: String
        let description: String
        let project_type: String
        let status: String
        let stars: Int
        let is_private: Bool
        let read_only: Bool
        let release_date: String
        let demo_date: String
        let created_at: Date
        let updated_at: Date
        let author_name: String
        let my_vote: Int
        let recent_comments: [Comment.CodingData]
        //let platforms: ??? // null in sample - type unknown
    }
}

extension Project.CodingData {
    var decoded: Project {
        .init(
            uid: uid,
            slug: slug,
            userId: user_uid,
            title: title,
            description: description,
            projectType: project_type,
            status: status,
            stars: stars,
            isPrivate: is_private,
            readOnly: read_only,
            releaseDate: release_date,
            demoDate: demo_date,
            createdAt: created_at,
            updatedAt: updated_at,
            authorName: author_name,
            myVote: my_vote,
            recentComments: recent_comments.map(\.decoded),
        )
    }
}
