import Foundation

private func isDebug() -> Bool {
    #if DEBUG
        return true
    #else
        return false
    #endif
}

private let timestampFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter
}()

func dlog(_ message: String) {
    if isDebug() {
        let timestamp = timestampFormatter.string(from: Date())
        let text = "\(timestamp) \n\(message)"
        print("\n\(text)")
    }
}

func dlog(_ error: Error) {
    dlog("\(error)")
}
