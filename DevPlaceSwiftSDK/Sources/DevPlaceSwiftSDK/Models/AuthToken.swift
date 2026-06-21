import Foundation

public struct AuthToken: Hashable, Sendable {
    public let tokenType: String
    public let accessToken: String
    public let expireTime: Date
    
    public init(tokenType: String, accessToken: String, expireTime: Date) {
        self.tokenType = tokenType
        self.accessToken = accessToken
        self.expireTime = expireTime
    }
    
    public var isExpired: Bool {
        expireTime < Date()
    }
    
    public var willExpireSoon: Bool {
        let oneHour: TimeInterval = 3600
        return expireTime.timeIntervalSinceNow < oneHour
    }
}

public extension AuthToken {
    struct CodingData: Codable {
        public let token_type: String
        public let access_token: String
        public let expires_in: Int
    }
}

public extension AuthToken.CodingData {
    var decoded: AuthToken {
        .init(
            tokenType: token_type,
            accessToken: access_token,
            expireTime: Date(timeIntervalSinceNow: TimeInterval(expires_in))
        )
    }
}
