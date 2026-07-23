import Foundation
import DevPlaceSwiftSDK

extension Poll {
    static var mockLayoutContainer: Poll {
        .init(
            id: "poll-1",
            question: "Which SwiftUI layout container do you reach for first?",
            options: [
                .init(id: "poll-1-opt-1", label: "VStack", count: 12, votes: 12, pct: 60),
                .init(id: "poll-1-opt-2", label: "HStack", count: 4, votes: 4, pct: 20),
                .init(id: "poll-1-opt-3", label: "ZStack", count: 2, votes: 2, pct: 10),
                .init(id: "poll-1-opt-4", label: "LazyVGrid", count: 2, votes: 2, pct: 10),
            ],
            total: 20,
            myChoice: nil,
            voted: nil,
        )
    }
    
    static var mockTestingFrameworkAlreadyVoted: Poll {
        .init(
            id: "poll-2",
            question: "Which testing framework do you prefer for new Swift code?",
            options: [
                .init(id: "poll-2-opt-1", label: "Swift Testing", count: 27, votes: 27, pct: 75),
                .init(id: "poll-2-opt-2", label: "XCTest", count: 9, votes: 9, pct: 25),
            ],
            total: 36,
            myChoice: "poll-2-opt-1",
            voted: "poll-2-opt-1",
        )
    }
    
    static var mockConcurrency: Poll {
        .init(
            id: "poll-3",
            question: "What's your preferred concurrency style in Swift today?",
            options: [
                .init(id: "poll-3-opt-1", label: "async/await", count: 41, votes: 41, pct: 82),
                .init(id: "poll-3-opt-2", label: "Combine", count: 5, votes: 5, pct: 10),
                .init(id: "poll-3-opt-3", label: "GCD", count: 3, votes: 3, pct: 6),
                .init(id: "poll-3-opt-4", label: "OperationQueue", count: 1, votes: 1, pct: 2),
            ],
            total: 50,
            myChoice: nil,
            voted: nil,
        )
    }
}
