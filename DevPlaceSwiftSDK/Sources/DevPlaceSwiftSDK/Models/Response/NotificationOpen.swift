public struct NotificationOpen: Hashable, Sendable {
    public let ok: Bool
    public let redirect: String
    //public let data: ? // always null in observed responses; type unknown

    public init(
        ok: Bool,
        redirect: String,
    ) {
        self.ok = ok
        self.redirect = redirect
    }
}

extension NotificationOpen {
    struct CodingData: Decodable {
        let ok: Bool
        let redirect: String
        //let data: ? // always null in observed responses; type unknown
    }
}

extension NotificationOpen.CodingData {
    var decoded: NotificationOpen {
        .init(
            ok: ok,
            redirect: redirect,
        )
    }
}
