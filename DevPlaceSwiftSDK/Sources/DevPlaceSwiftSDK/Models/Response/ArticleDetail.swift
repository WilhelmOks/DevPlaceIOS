import Foundation

public struct ArticleDetail: Hashable, Sendable, Identifiable {
    public var id: String { "article:" + article.id }
    public let article: Article.Data
    public let canonicalSlug: String
    public let imageUrl: String
    public let grade: Int
    //public let timeAgo: String // exists in API; format on demand from article.createdAt
    public let comments: [Comment]
    public let bookmarked: Bool

    public init(
        article: Article.Data,
        canonicalSlug: String,
        imageUrl: String,
        grade: Int,
        comments: [Comment],
        bookmarked: Bool,
    ) {
        self.article = article
        self.canonicalSlug = canonicalSlug
        self.imageUrl = imageUrl
        self.grade = grade
        self.comments = comments
        self.bookmarked = bookmarked
    }
}

extension ArticleDetail {
    struct CodingData: Decodable {
        let article: Article.Data.CodingData
        let canonical_slug: String
        let image_url: String
        let grade: Int
        //let time_ago: String // not needed because it is formatted on demand from created_at
        let comments: [Comment.CodingData]
        let bookmarked: Bool
    }
}

extension ArticleDetail.CodingData {
    var decoded: ArticleDetail {
        .init(
            article: article.decoded,
            canonicalSlug: canonical_slug,
            imageUrl: image_url,
            grade: grade,
            comments: comments.map(\.decoded),
            bookmarked: bookmarked,
        )
    }
}
