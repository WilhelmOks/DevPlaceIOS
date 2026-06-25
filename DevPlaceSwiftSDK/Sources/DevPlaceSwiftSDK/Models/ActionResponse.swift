public struct ActionResponse<Payload: Decodable & Hashable & Sendable>: Decodable, Hashable, Sendable {
    public let ok: Bool
    public let redirect: String
    public let data: Payload?

    public init(
        ok: Bool,
        redirect: String,
        data: Payload?,
    ) {
        self.ok = ok
        self.redirect = redirect
        self.data = data
    }
}

public struct EmptyActionPayload: Decodable, Hashable, Sendable {
    public init() {}

    public init(from decoder: Decoder) throws {}
}
