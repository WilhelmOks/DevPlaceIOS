import Foundation
import DevPlaceSwiftSDK

extension Collection where Element == Comment {
    static var mock: [Element] {
        [
            .init(
                data: .init(
                    id: "c1",
                    userId: "u2",
                    content: "Interesting. I'm not sure I buy that this is a feature worth investing in.",
                    parentId: nil,
                    targetType: "post",
                    targetId: "1",
                    createdAt: Date().addingTimeInterval(-60 * 11),
                ),
                author: .mock2,
                myVote: 0,
                votes: .init(up: 0, down: 0),
                attachments: [],
            ),
            .init(
                data: .init(
                    id: "c2",
                    userId: "u1",
                    content: "Good point. Sounds like a great idea.",
                    parentId: "c1",
                    targetType: "post",
                    targetId: "1",
                    createdAt: Date().addingTimeInterval(-60 * 5),
                ),
                author: .mock,
                myVote: 1,
                votes: .init(up: 2, down: 0),
                attachments: [],
            ),
        ]
    }
}
