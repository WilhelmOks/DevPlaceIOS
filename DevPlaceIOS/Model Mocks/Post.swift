import Foundation
import DevPlaceSwiftSDK

extension Collection where Element == Post {
    static var mock: [Element] {
        [
            .init(data: .init(id: "1", content: "Hello World!")),
            .init(data: .init(id: "2", content: "Content of the second post")),
        ]
    }
}
