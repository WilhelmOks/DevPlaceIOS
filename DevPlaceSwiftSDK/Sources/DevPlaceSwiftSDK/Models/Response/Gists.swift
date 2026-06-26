import Foundation

public struct Gists: Hashable, Sendable {
    public let gists: [Gist]
    public let totalCount: Int
    public let nextCursor: Date?
    public let currentLanguage: String
    public let search: String
    public let languages: [[String]]
    public let gistLanguageCodes: [String]

    public init(
        gists: [Gist],
        totalCount: Int,
        nextCursor: Date?,
        currentLanguage: String,
        search: String,
        languages: [[String]],
        gistLanguageCodes: [String],
    ) {
        self.gists = gists
        self.totalCount = totalCount
        self.nextCursor = nextCursor
        self.currentLanguage = currentLanguage
        self.search = search
        self.languages = languages
        self.gistLanguageCodes = gistLanguageCodes
    }
}

extension Gists {
    struct CodingData: Decodable {
        let gists: [Gist.CodingData]
        let total_count: Int
        let next_cursor: Date?
        let current_language: String
        let search: String
        let languages: [[String]]
        let gist_language_codes: [String]
    }
}

extension Gists.CodingData {
    var decoded: Gists {
        .init(
            gists: gists.map(\.decoded),
            totalCount: total_count,
            nextCursor: next_cursor,
            currentLanguage: current_language,
            search: search,
            languages: languages,
            gistLanguageCodes: gist_language_codes,
        )
    }
}
