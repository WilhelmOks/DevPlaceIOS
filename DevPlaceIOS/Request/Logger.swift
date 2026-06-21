import KreeRequest

struct DevPlaceRequestLogger: Logger {
    func log(_ message: String) {
        dlog(message)
    }
}
