public struct Post: Hashable, Sendable, Identifiable {
    public var id: String { "post:" + data.id }
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
}

public extension Post {
    public struct Data: Hashable, Sendable, Identifiable {
        public let id: String
        public let content: String
        
        public init(id: String, content: String) {
            self.id = id
            self.content = content
        }
    }
}

extension Post {
    struct CodingData: Decodable {
        let post: Data.CodingData
    }
}

extension Post.Data {
    struct CodingData: Decodable {
        let uid: String
        let content: String
    }
}

extension Post.CodingData {
    var decoded: Post {
        .init(
            data: post.decoded
        )
    }
}

extension Post.Data.CodingData {
    var decoded: Post.Data {
        .init(
            id: uid,
            content: content
        )
    }
}
