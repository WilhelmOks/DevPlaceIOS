import Foundation

public struct Bookmarks: Hashable, Sendable {
    public let items: [BookmarkItem]
    public let nextCursor: Date?

    public init(
        items: [BookmarkItem],
        nextCursor: Date?,
    ) {
        self.items = items
        self.nextCursor = nextCursor
    }
}

extension Bookmarks {
    struct CodingData: Decodable {
        let items: [BookmarkItem.CodingData]
        let next_cursor: Date?
    }
}

extension Bookmarks.CodingData {
    var decoded: Bookmarks {
        .init(
            items: items.map(\.decoded),
            nextCursor: next_cursor,
        )
    }
}
