enum TextCharacterCounter {
    static func numberOfCharacters(_ text: String) -> Int {
        text.utf16.count // "wrong" counting, to replicate how the web app and the backend is counting.
    }
}
