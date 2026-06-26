import Foundation

public struct Post: Hashable, Sendable, Identifiable {
    public var id: String { "post:" + data.id }
    public let data: Data
    public let author: User
    public let myVote: Int
    public let commentCount: Int
    public let recentComments: [Comment]
    public let bookmarked: Bool
    public let attachments: [Attachment]
    public let poll: Poll?
    //public let reactions: ??? // empty in sample - type unknown

    public init(
        data: Data,
        author: User,
        myVote: Int,
        commentCount: Int,
        recentComments: [Comment],
        bookmarked: Bool,
        attachments: [Attachment],
        poll: Poll?,
    ) {
        self.data = data
        self.author = author
        self.myVote = myVote
        self.commentCount = commentCount
        self.recentComments = recentComments
        self.bookmarked = bookmarked
        self.attachments = attachments
        self.poll = poll
    }
}

public extension Post {
    public struct Data: Hashable, Sendable, Identifiable {
        public let id: String
        public let title: String?
        public let topic: String?
        public let content: String
        public let slug: String?
        public let userId: String
        public let stars: Int
        public let image: String?
        public let createdAt: Date
        public let updatedAt: Date?

        public init(
            id: String,
            title: String?,
            topic: String?,
            content: String,
            slug: String?,
            userId: String,
            stars: Int,
            image: String?,
            createdAt: Date,
            updatedAt: Date?,
        ) {
            self.id = id
            self.title = title
            self.topic = topic
            self.content = content
            self.slug = slug
            self.userId = userId
            self.stars = stars
            self.image = image
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

extension Post {
    struct CodingData: Decodable {
        let post: Data.CodingData
        let author: User.CodingData
        //let time_ago: String // not needed because it is formatted by demand by using the creation time or edit time.
        let my_vote: Int
        let comment_count: Int
        let recent_comments: [Comment.CodingData]
        let bookmarked: Bool
        let attachments: [Attachment.CodingData]
        let poll: Poll.CodingData?
        //let reactions: ??? // empty in sample - type unknown
    }
}

extension Post.Data {
    struct CodingData: Decodable {
        let uid: String
        let title: String?
        let topic: String?
        let content: String
        let slug: String?
        let user_uid: String
        let stars: Int
        let image: String?
        let created_at: Date
        let updated_at: Date?
    }
}

extension Post.CodingData {
    var decoded: Post {
        .init(
            data: post.decoded,
            author: author.decoded,
            myVote: my_vote,
            commentCount: comment_count,
            recentComments: recent_comments.map(\.decoded),
            bookmarked: bookmarked,
            attachments: attachments.map(\.decoded),
            poll: poll?.decoded,
        )
    }
}

extension Post.Data.CodingData {
    var decoded: Post.Data {
        .init(
            id: uid,
            title: title,
            topic: topic,
            content: content,
            slug: slug,
            userId: user_uid,
            stars: stars,
            image: image,
            createdAt: created_at,
            updatedAt: updated_at,
        )
    }
}
