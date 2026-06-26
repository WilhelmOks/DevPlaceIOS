import Foundation

public struct Poll: Hashable, Sendable, Identifiable {
    public let id: String
    public let question: String
    public let options: [PollOption]
    public let total: Int
    public let myChoice: String
    public let voted: String

    public init(
        id: String,
        question: String,
        options: [PollOption],
        total: Int,
        myChoice: String,
        voted: String,
    ) {
        self.id = id
        self.question = question
        self.options = options
        self.total = total
        self.myChoice = myChoice
        self.voted = voted
    }
}

extension Poll {
    struct CodingData: Decodable {
        let uid: String
        let question: String
        let options: [PollOption.CodingData]
        let total: Int
        let my_choice: String
        let voted: String
    }
}

extension Poll.CodingData {
    var decoded: Poll {
        .init(
            id: uid,
            question: question,
            options: options.map(\.decoded),
            total: total,
            myChoice: my_choice,
            voted: voted,
        )
    }
}
