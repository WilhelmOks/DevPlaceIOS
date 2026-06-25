import Foundation

public struct PostDetail: Hashable, Sendable, Identifiable {
    public var id: String { "post:" + post.id }
    public let post: Post.Data
    public let author: User
    public let isOwner: Bool
    public let starCount: Int
    public let myVote: Int
    //public let timeAgo: String // exists in API; format on demand from post.createdAt
    public let comments: [Comment]
    public let attachments: [Attachment]
    public let bookmarked: Bool
    public let poll: Poll?
    public let commentCount: Int
    public let relatedPosts: [Post]
    public let topics: [String]
    //public let reactions: ??? // empty in sample - type unknown

    public init(
        post: Post.Data,
        author: User,
        isOwner: Bool,
        starCount: Int,
        myVote: Int,
        comments: [Comment],
        attachments: [Attachment],
        bookmarked: Bool,
        poll: Poll?,
        commentCount: Int,
        relatedPosts: [Post],
        topics: [String],
    ) {
        self.post = post
        self.author = author
        self.isOwner = isOwner
        self.starCount = starCount
        self.myVote = myVote
        self.comments = comments
        self.attachments = attachments
        self.bookmarked = bookmarked
        self.poll = poll
        self.commentCount = commentCount
        self.relatedPosts = relatedPosts
        self.topics = topics
    }
}

extension PostDetail {
    struct CodingData: Decodable {
        let post: Post.Data.CodingData
        let author: User.CodingData
        let is_owner: Bool
        let star_count: Int
        let my_vote: Int
        //let time_ago: String // not needed because it is formatted on demand from created_at
        let comments: [Comment.CodingData]
        let attachments: [Attachment.CodingData]
        let bookmarked: Bool
        let poll: Poll.CodingData?
        let comment_count: Int
        let related_posts: [Post.CodingData]
        let topics: [String]
        //let reactions: ??? // empty in sample - type unknown
    }
}

extension PostDetail.CodingData {
    var decoded: PostDetail {
        .init(
            post: post.decoded,
            author: author.decoded,
            isOwner: is_owner,
            starCount: star_count,
            myVote: my_vote,
            comments: comments.map(\.decoded),
            attachments: attachments.map(\.decoded),
            bookmarked: bookmarked,
            poll: poll?.decoded,
            commentCount: comment_count,
            relatedPosts: related_posts.map(\.decoded),
            topics: topics,
        )
    }
}
