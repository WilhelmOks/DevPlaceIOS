import Foundation

public struct Article: Hashable, Sendable, Identifiable {
    public var id: String { "article:" + data.id }
    public let data: Data
    //public let timeAgo: String // exists in API; format on demand from data.createdAt
    public let imageUrl: String
    public let grade: Int
    public let featured: Int
    public let recentComments: [Comment]

    public init(
        data: Data,
        imageUrl: String,
        grade: Int,
        featured: Int,
        recentComments: [Comment],
    ) {
        self.data = data
        self.imageUrl = imageUrl
        self.grade = grade
        self.featured = featured
        self.recentComments = recentComments
    }
}

public extension Article {
    struct Data: Hashable, Sendable, Identifiable {
        public let id: String
        public let slug: String
        public let title: String
        public let description: String
        public let content: String
        public let url: String
        public let sourceName: String
        public let author: String
        public let grade: Int
        public let aiGrade: Int
        public let status: String
        public let imageUrl: String
        public let featured: Int
        public let hasUniqueImage: Int
        public let articlePublished: String
        public let createdAt: Date
        public let syncedAt: Date

        public init(
            id: String,
            slug: String,
            title: String,
            description: String,
            content: String,
            url: String,
            sourceName: String,
            author: String,
            grade: Int,
            aiGrade: Int,
            status: String,
            imageUrl: String,
            featured: Int,
            hasUniqueImage: Int,
            articlePublished: String,
            createdAt: Date,
            syncedAt: Date,
        ) {
            self.id = id
            self.slug = slug
            self.title = title
            self.description = description
            self.content = content
            self.url = url
            self.sourceName = sourceName
            self.author = author
            self.grade = grade
            self.aiGrade = aiGrade
            self.status = status
            self.imageUrl = imageUrl
            self.featured = featured
            self.hasUniqueImage = hasUniqueImage
            self.articlePublished = articlePublished
            self.createdAt = createdAt
            self.syncedAt = syncedAt
        }
    }
}

extension Article {
    struct CodingData: Decodable {
        let article: Data.CodingData
        //let time_ago: String // not needed because it is formatted on demand from created_at
        let image_url: String
        let grade: Int
        let featured: Int
        let recent_comments: [Comment.CodingData]
    }
}

extension Article.Data {
    struct CodingData: Decodable {
        let uid: String
        let slug: String
        let title: String
        let description: String
        let content: String
        let url: String
        let source_name: String
        let author: String
        let grade: Int
        let ai_grade: Int
        let status: String
        let image_url: String
        let featured: Int
        let has_unique_image: Int
        let article_published: String
        let created_at: Date
        let synced_at: Date
    }
}

extension Article.CodingData {
    var decoded: Article {
        .init(
            data: article.decoded,
            imageUrl: image_url,
            grade: grade,
            featured: featured,
            recentComments: recent_comments.map(\.decoded),
        )
    }
}

extension Article.Data.CodingData {
    var decoded: Article.Data {
        .init(
            id: uid,
            slug: slug,
            title: title,
            description: description,
            content: content,
            url: url,
            sourceName: source_name,
            author: author,
            grade: grade,
            aiGrade: ai_grade,
            status: status,
            imageUrl: image_url,
            featured: featured,
            hasUniqueImage: has_unique_image,
            articlePublished: article_published,
            createdAt: created_at,
            syncedAt: synced_at,
        )
    }
}
