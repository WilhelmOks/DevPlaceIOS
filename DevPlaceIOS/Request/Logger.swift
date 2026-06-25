import KreeRequest

struct DevPlaceRequestLogger: Logger {
    func log(_ message: String) {
        Task { @MainActor in
            dlog(message)
        }
    }
}
