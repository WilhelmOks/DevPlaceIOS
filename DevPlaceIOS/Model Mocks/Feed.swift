import Foundation
import DevPlaceSwiftSDK

extension Feed {
    static var mock: Self {
        .init(
            posts: .mock,
            currentTab: "all",
            currentTopic: "random",
            search: "",
            nextCursor: nil,
            totalMembers: 0,
            postsToday: 0,
            totalProjects: 0,
            totalGists: 0,
            topAuthors: [.mock, .mock2],
        )
    }
}
