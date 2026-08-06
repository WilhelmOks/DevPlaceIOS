import Foundation

public struct MessagesWebSocketTicket: Hashable, Sendable {
    public let ticket: String
    public let expiresIn: Int

    public init(ticket: String, expiresIn: Int) {
        self.ticket = ticket
        self.expiresIn = expiresIn
    }
}

extension MessagesWebSocketTicket {
    struct CodingData: Decodable {
        let ticket: String
        let expires_in: Int
    }
}

extension MessagesWebSocketTicket.CodingData {
    var decoded: MessagesWebSocketTicket {
        .init(
            ticket: ticket,
            expiresIn: expires_in,
        )
    }
}
