import Foundation

enum MentionToken {
    struct Active: Equatable {
        let range: Range<String.Index>
        let query: String
    }

    static func active(in text: String, caret: String.Index?) -> Active? {
        let caret = min(caret ?? text.endIndex, text.endIndex)

        var cursor = caret
        while cursor > text.startIndex {
            let previous = text.index(before: cursor)
            let character = text[previous]

            if character == "@" {
                let isWordStart = previous == text.startIndex || text[text.index(before: previous)].isWhitespace
                guard isWordStart else {
                    return nil
                }
                let query = String(text[cursor..<caret])
                var end = caret
                while end < text.endIndex, isMentionCharacter(text[end]) {
                    end = text.index(after: end)
                }
                return Active(range: previous..<end, query: query)
            }

            guard isMentionCharacter(character) else {
                return nil
            }
            cursor = previous
        }
        return nil
    }

    private static func isMentionCharacter(_ character: Character) -> Bool {
        character.isLetter || character.isNumber || character == "_"
    }
}
