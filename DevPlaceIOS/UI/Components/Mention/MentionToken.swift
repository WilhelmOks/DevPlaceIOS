import Foundation

enum MentionToken {
    struct Active: Equatable {
        let range: Range<String.Index>
        let query: String
    }

    static func active(in text: String) -> Active? {
        let wordStart = text.lastIndex(where: \.isWhitespace).map { text.index(after: $0) } ?? text.startIndex
        let word = text[wordStart...]
        guard word.first == "@" else {
            return nil
        }
        let query = String(word.dropFirst())
        guard !query.contains("@") else {
            return nil
        }
        return Active(range: wordStart..<text.endIndex, query: query)
    }
}
