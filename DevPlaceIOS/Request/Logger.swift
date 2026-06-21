import KreeRequest

struct DevPlaceRequestLogger: Logger {
    func log(_ message: String) {
        print(message) //TODO: only print in DEBUG
        print()
    }
}
