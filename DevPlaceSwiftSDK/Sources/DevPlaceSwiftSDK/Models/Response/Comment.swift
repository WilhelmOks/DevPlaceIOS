import Foundation

public struct Comment: Hashable, Sendable, Identifiable {
    public var id: String { "comment:" + data.id }
    public let data: Data
    public let author: User
    //public let timeAgo: String // exists in API; format on demand from data.createdAt
    public let myVote: Vote
    public let votes: Votes
    public let attachments: [Attachment]
    public let children: [Comment]
    //public let reactions: ??? // empty in sample - type unknown

    public var voteCount: Int {
        votes.up - votes.down
    }

    public init(
        data: Data,
        author: User,
        myVote: Vote,
        votes: Votes,
        attachments: [Attachment],
        children: [Comment],
    ) {
        self.data = data
        self.author = author
        self.myVote = myVote
        self.votes = votes
        self.attachments = attachments
        self.children = children
    }
}

public extension Comment {
    struct Data: Hashable, Sendable, Identifiable {
        public let id: String
        public let userId: String
        public let content: String
        public let parentId: String?
        public let targetType: String
        public let targetId: String
        public let createdAt: Date

        public init(
            id: String,
            userId: String,
            content: String,
            parentId: String?,
            targetType: String,
            targetId: String,
            createdAt: Date,
        ) {
            self.id = id
            self.userId = userId
            self.content = content
            self.parentId = parentId
            self.targetType = targetType
            self.targetId = targetId
            self.createdAt = createdAt
        }
    }

    struct Votes: Hashable, Sendable {
        public let up: Int
        public let down: Int

        public init(up: Int, down: Int) {
            self.up = up
            self.down = down
        }
    }
}

extension Comment {
    struct CodingData: Decodable {
        let comment: Data.CodingData
        let author: User.CodingData
        //let time_ago: String // not needed because it is formatted on demand from created_at
        let my_vote: Int
        let votes: Votes.CodingData
        let attachments: [Attachment.CodingData]
        let children: [Comment.CodingData]
        //let reactions: ??? // empty in sample - type unknown
    }
}

extension Comment.Data {
    struct CodingData: Decodable {
        let uid: String
        let user_uid: String
        let content: String
        let parent_uid: String?
        let target_type: String
        let target_uid: String
        let created_at: Date
    }
}

extension Comment.Votes {
    struct CodingData: Decodable {
        let up: Int
        let down: Int
    }
}

extension Comment.CodingData {
    var decoded: Comment {
        .init(
            data: comment.decoded,
            author: author.decoded,
            myVote: Vote(value: my_vote),
            votes: votes.decoded,
            attachments: attachments.map(\.decoded),
            children: children.map(\.decoded),
        )
    }
}

extension Comment.Data.CodingData {
    var decoded: Comment.Data {
        .init(
            id: uid,
            userId: user_uid,
            content: content,
            parentId: parent_uid,
            targetType: target_type,
            targetId: target_uid,
            createdAt: created_at,
        )
    }
}

extension Comment.Votes.CodingData {
    var decoded: Comment.Votes {
        .init(up: up, down: down)
    }
}
