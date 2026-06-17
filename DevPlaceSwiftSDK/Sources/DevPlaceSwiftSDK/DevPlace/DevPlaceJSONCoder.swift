import Foundation
import KreeRequest

extension JSONEncoder {
    static let devPlace: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

extension JSONDecoder {
    static let devPlace: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithOptionalFractionalSeconds
        return decoder
    }()
}
