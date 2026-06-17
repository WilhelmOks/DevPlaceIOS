public struct Feed: Hashable, Sendable {
    public let posts: [Post]
    
    public init(posts: [Post]) {
        self.posts = posts
    }
}

extension Feed {
    struct CodingData: Decodable {
        let posts: [Post.CodingData]
    }
}

extension Feed.CodingData {
    var decoded: Feed {
        .init(
            posts: posts.map(\.decoded)
        )
    }
}
