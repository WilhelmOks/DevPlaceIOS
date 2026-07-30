enum TextCharacterCounter {
    static func numberOfCharacters(_ text: String) -> Int {
        text.utf16.count // "wrong" counting, to replicate how the web app is counting. Turns out that the backend is counting differently. Waiting to be fixed...
    }
}
