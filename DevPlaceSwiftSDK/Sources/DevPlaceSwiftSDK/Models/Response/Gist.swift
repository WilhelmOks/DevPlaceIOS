import Foundation

public struct Gist: Hashable, Sendable, Identifiable {
    public var id: String { "gist:" + data.id }
    public let data: Data
    public let author: User?
    //public let timeAgo: String // exists in API; format on demand from data.createdAt
    public let myVote: Vote
    public let commentCount: Int
    public let recentComments: [Comment]

    public init(
        data: Data,
        author: User?,
        myVote: Vote,
        commentCount: Int,
        recentComments: [Comment],
    ) {
        self.data = data
        self.author = author
        self.myVote = myVote
        self.commentCount = commentCount
        self.recentComments = recentComments
    }
}

public extension Gist {
    struct Data: Hashable, Sendable, Identifiable {
        public let id: String
        public let slug: String
        public let userId: String
        public let title: String
        public let description: String
        public let sourceCode: String
        public let language: String
        public let stars: Int
        public let createdAt: Date
        public let updatedAt: Date?

        public init(
            id: String,
            slug: String,
            userId: String,
            title: String,
            description: String,
            sourceCode: String,
            language: String,
            stars: Int,
            createdAt: Date,
            updatedAt: Date?,
        ) {
            self.id = id
            self.slug = slug
            self.userId = userId
            self.title = title
            self.description = description
            self.sourceCode = sourceCode
            self.language = language
            self.stars = stars
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

extension Gist {
    struct CodingData: Decodable {
        let gist: Data.CodingData
        let author: User.CodingData?
        //let time_ago: String // not needed because it is formatted on demand from created_at
        let my_vote: Int
        let comment_count: Int
        let recent_comments: [Comment.CodingData]
    }
}

extension Gist.Data {
    struct CodingData: Decodable {
        let uid: String
        let slug: String
        let user_uid: String
        let title: String
        let description: String
        let source_code: String
        let language: String
        let stars: Int
        let created_at: Date
        let updated_at: Date?
    }
}

extension Gist.CodingData {
    var decoded: Gist {
        .init(
            data: gist.decoded,
            author: author?.decoded,
            myVote: Vote(value: my_vote),
            commentCount: comment_count,
            recentComments: recent_comments.map(\.decoded),
        )
    }
}

extension Gist.Data.CodingData {
    var decoded: Gist.Data {
        .init(
            id: uid,
            slug: slug,
            userId: user_uid,
            title: title,
            description: description,
            sourceCode: source_code,
            language: language,
            stars: stars,
            createdAt: created_at,
            updatedAt: updated_at,
        )
    }
}
