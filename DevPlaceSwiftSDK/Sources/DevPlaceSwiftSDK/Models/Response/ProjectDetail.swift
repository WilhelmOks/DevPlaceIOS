import Foundation

public struct ProjectDetail: Hashable, Sendable, Identifiable {
    public var id: String { "project:" + project.id }
    public let project: Project.Data
    public let author: User
    public let isOwner: Bool
    public let starCount: Int
    public let myVote: Vote
    //public let timeAgo: String // exists in API; format on demand from project.createdAt
    public let comments: [Comment]
    public let attachments: [Attachment]
    public let bookmarked: Bool
    public let isPrivate: Bool
    public let readOnly: Bool
    public let forkCount: Int
    public let fileCount: Int
    //public let platforms: ??? // null in sample - type unknown
    //public let forkedFrom: ??? // empty object in sample - type unknown
    //public let reactions: ??? // empty in sample - type unknown

    public init(
        project: Project.Data,
        author: User,
        isOwner: Bool,
        starCount: Int,
        myVote: Vote,
        comments: [Comment],
        attachments: [Attachment],
        bookmarked: Bool,
        isPrivate: Bool,
        readOnly: Bool,
        forkCount: Int,
        fileCount: Int,
    ) {
        self.project = project
        self.author = author
        self.isOwner = isOwner
        self.starCount = starCount
        self.myVote = myVote
        self.comments = comments
        self.attachments = attachments
        self.bookmarked = bookmarked
        self.isPrivate = isPrivate
        self.readOnly = readOnly
        self.forkCount = forkCount
        self.fileCount = fileCount
    }
}

extension ProjectDetail {
    struct CodingData: Decodable {
        let project: Project.Data.CodingData
        let author: User.CodingData
        let is_owner: Bool
        let star_count: Int
        let my_vote: Int
        //let time_ago: String // not needed because it is formatted on demand from created_at
        let comments: [Comment.CodingData]
        let attachments: [Attachment.CodingData]
        let bookmarked: Bool
        let is_private: Bool
        let read_only: Bool
        let fork_count: Int
        let file_count: Int
        //let platforms: ??? // null in sample - type unknown
        //let forked_from: ??? // empty object in sample - type unknown
        //let reactions: ??? // empty in sample - type unknown
    }
}

extension ProjectDetail.CodingData {
    var decoded: ProjectDetail {
        .init(
            project: project.decoded,
            author: author.decoded,
            isOwner: is_owner,
            starCount: star_count,
            myVote: Vote(value: my_vote),
            comments: comments.map(\.decoded),
            attachments: attachments.map(\.decoded),
            bookmarked: bookmarked,
            isPrivate: is_private,
            readOnly: read_only,
            forkCount: fork_count,
            fileCount: file_count,
        )
    }
}
