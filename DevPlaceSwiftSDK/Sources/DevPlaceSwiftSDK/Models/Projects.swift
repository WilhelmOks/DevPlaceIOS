import Foundation

public struct Projects: Hashable, Sendable {
    public let projects: [Project]
    public let currentTab: String
    public let search: String
    public let projectType: String
    public let totalCount: Int
    public let nextCursor: Date?
    public let totalMembers: Int
    public let topAuthors: [User]

    public init(
        projects: [Project],
        currentTab: String,
        search: String,
        projectType: String,
        totalCount: Int,
        nextCursor: Date?,
        totalMembers: Int,
        topAuthors: [User],
    ) {
        self.projects = projects
        self.currentTab = currentTab
        self.search = search
        self.projectType = projectType
        self.totalCount = totalCount
        self.nextCursor = nextCursor
        self.totalMembers = totalMembers
        self.topAuthors = topAuthors
    }
}

extension Projects {
    struct CodingData: Decodable {
        let projects: [Project.CodingData]
        let current_tab: String
        let search: String
        let project_type: String
        let total_count: Int
        let next_cursor: Date?
        let total_members: Int
        let top_authors: [User.CodingData]
    }
}

extension Projects.CodingData {
    var decoded: Projects {
        .init(
            projects: projects.map(\.decoded),
            currentTab: current_tab,
            search: search,
            projectType: project_type,
            totalCount: total_count,
            nextCursor: next_cursor,
            totalMembers: total_members,
            topAuthors: top_authors.map(\.decoded),
        )
    }
}
