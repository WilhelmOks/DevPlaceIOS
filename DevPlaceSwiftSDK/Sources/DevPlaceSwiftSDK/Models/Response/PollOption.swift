import Foundation

public struct PollOption: Hashable, Sendable, Identifiable {
    public let id: String
    public let label: String
    public let count: Int
    public let votes: Int
    public let pct: Int

    public init(
        id: String,
        label: String,
        count: Int,
        votes: Int,
        pct: Int,
    ) {
        self.id = id
        self.label = label
        self.count = count
        self.votes = votes
        self.pct = pct
    }
}

extension PollOption {
    struct CodingData: Decodable {
        let uid: String
        let label: String
        let count: Int
        let votes: Int?
        let pct: Int
    }
}

extension PollOption.CodingData {
    var decoded: PollOption {
        .init(
            id: uid,
            label: label,
            count: count,
            votes: votes ?? 0,
            pct: pct,
        )
    }
}
