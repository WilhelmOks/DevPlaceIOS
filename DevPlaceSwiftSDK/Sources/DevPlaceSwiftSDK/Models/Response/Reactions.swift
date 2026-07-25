import Foundation

public struct Reactions: Hashable, Sendable {
    public let mine: [String]
    public let counts: [String: Int]

    public init(
        mine: [String],
        counts: [String: Int],
    ) {
        self.mine = mine
        self.counts = counts
    }
}

extension Reactions {
    struct CodingData: Decodable {
        let mine: [String]
        let counts: [String: Int]
    }
}

extension Reactions.CodingData {
    var decoded: Reactions {
        .init(
            mine: mine,
            counts: counts,
        )
    }
}
