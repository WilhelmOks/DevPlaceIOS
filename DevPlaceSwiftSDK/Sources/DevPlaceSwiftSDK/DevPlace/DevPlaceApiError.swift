/// Represents an error coming directly from the DevPlace API.
public struct DevPlaceApiError: Swift.Error {
    public let message: String
}

public extension DevPlaceApiError {
    struct CodingData: Decodable, Swift.Error {
        let error: String
    }
}

public extension DevPlaceApiError.CodingData {
    var decoded: DevPlaceApiError {
        .init(message: error)
    }
}
