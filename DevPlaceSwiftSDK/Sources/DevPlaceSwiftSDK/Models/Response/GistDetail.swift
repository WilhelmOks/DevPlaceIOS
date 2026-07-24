import Foundation

public struct GistDetail: Hashable, Sendable, Identifiable {
    public var id: String { "gist:" + gist.id }
    public let gist: Gist.Data
    public let author: User
    public let isOwner: Bool
    public let starCount: Int
    public let myVote: Vote
    //public let timeAgo: String // exists in API; format on demand from gist.createdAt
    public let comments: [Comment]
    public let attachments: [Attachment]
    public let bookmarked: Bool
    //public let reactions: ??? // empty in sample - type unknown

    public init(
        gist: Gist.Data,
        author: User,
        isOwner: Bool,
        starCount: Int,
        myVote: Vote,
        comments: [Comment],
        attachments: [Attachment],
        bookmarked: Bool,
    ) {
        self.gist = gist
        self.author = author
        self.isOwner = isOwner
        self.starCount = starCount
        self.myVote = myVote
        self.comments = comments
        self.attachments = attachments
        self.bookmarked = bookmarked
    }
}

extension GistDetail {
    struct CodingData: Decodable {
        let gist: Gist.Data.CodingData
        let author: User.CodingData
        let is_owner: Bool
        let star_count: Int
        let my_vote: Int
        //let time_ago: String // not needed because it is formatted on demand from created_at
        let comments: [Comment.CodingData]
        let attachments: [Attachment.CodingData]
        let bookmarked: Bool
        //let reactions: ??? // empty in sample - type unknown
    }
}

extension GistDetail.CodingData {
    var decoded: GistDetail {
        .init(
            gist: gist.decoded,
            author: author.decoded,
            isOwner: is_owner,
            starCount: star_count,
            myVote: Vote(value: my_vote),
            comments: comments.map(\.decoded),
            attachments: attachments.map(\.decoded),
            bookmarked: bookmarked,
        )
    }
}
