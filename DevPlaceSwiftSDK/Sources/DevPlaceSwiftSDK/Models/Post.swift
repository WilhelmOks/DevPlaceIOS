import Foundation

public struct Post: Hashable, Sendable, Identifiable {
    public var id: String { "post:" + data.id }
    public let data: Data
    
    public init(data: Data) {
        self.data = data
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
        //public let image: String?
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
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

extension Post {
    struct CodingData: Decodable {
        let post: Data.CodingData
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
        //let image: String?
        let created_at: Date
        let updated_at: Date?
    }
}

extension Post.CodingData {
    var decoded: Post {
        .init(
            data: post.decoded
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
            createdAt: created_at,
            updatedAt: updated_at,
        )
    }
}
