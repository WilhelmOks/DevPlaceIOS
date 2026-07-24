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
                    createdAt: Date().addingTimeInterval(-60 * 60),
                ),
                author: .mock2,
                myVote: .none,
                votes: .init(up: 3, down: 1),
                attachments: [],
                children: [
                    .init(
                        data: .init(
                            id: "c2",
                            userId: "u1",
                            content: "Good point, but the benchmarks tell a different story.",
                            parentId: "c1",
                            targetType: "post",
                            targetId: "1",
                            createdAt: Date().addingTimeInterval(-60 * 50),
                        ),
                        author: .mock,
                        myVote: .up,
                        votes: .init(up: 2, down: 0),
                        attachments: [],
                        children: [
                            .init(
                                data: .init(
                                    id: "c3",
                                    userId: "u2",
                                    content: "Which benchmarks are you referring to?",
                                    parentId: "c2",
                                    targetType: "post",
                                    targetId: "1",
                                    createdAt: Date().addingTimeInterval(-60 * 40),
                                ),
                                author: .mock2,
                                myVote: .none,
                                votes: .init(up: 1, down: 0),
                                attachments: [],
                                children: [
                                    .init(
                                        data: .init(
                                            id: "c4",
                                            userId: "u1",
                                            content: "The ones from the last release notes.",
                                            parentId: "c3",
                                            targetType: "post",
                                            targetId: "1",
                                            createdAt: Date().addingTimeInterval(-60 * 30),
                                        ),
                                        author: .mock,
                                        myVote: .none,
                                        votes: .init(up: 0, down: 0),
                                        attachments: [],
                                        children: [
                                            .init(
                                                data: .init(
                                                    id: "c5",
                                                    userId: "u2",
                                                    content: "Ah, that explains it. This reply is deep enough to be capped at the max indentation level.",
                                                    parentId: "c4",
                                                    targetType: "post",
                                                    targetId: "1",
                                                    createdAt: Date().addingTimeInterval(-60 * 20),
                                                ),
                                                author: .mock2,
                                                myVote: .down,
                                                votes: .init(up: 0, down: 1),
                                                attachments: [],
                                                children: [],
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ],
                    ),
                ],
            ),
            .init(
                data: .init(
                    id: "c6",
                    userId: "u1",
                    content: "Great write-up, thanks for sharing!",
                    parentId: nil,
                    targetType: "post",
                    targetId: "1",
                    createdAt: Date().addingTimeInterval(-60 * 10),
                ),
                author: .mock,
                myVote: .none,
                votes: .init(up: 5, down: 0),
                attachments: [],
                children: [],
            ),
        ]
    }
}
