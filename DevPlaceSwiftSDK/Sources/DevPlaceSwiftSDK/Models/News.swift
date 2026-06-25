import Foundation

public struct News: Hashable, Sendable {
    public let articles: [Article]
    public let nextCursor: Date?

    public init(
        articles: [Article],
        nextCursor: Date?,
    ) {
        self.articles = articles
        self.nextCursor = nextCursor
    }
}

extension News {
    struct CodingData: Decodable {
        let articles: [Article.CodingData]
        let next_cursor: Date?
    }
}

extension News.CodingData {
    var decoded: News {
        .init(
            articles: articles.map(\.decoded),
            nextCursor: next_cursor,
        )
    }
}
