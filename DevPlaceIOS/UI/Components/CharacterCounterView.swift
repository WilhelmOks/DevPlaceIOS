import SwiftUI

struct CharacterCounterView: View {
    let text: String
    var minCount: Int?
    let maxCount: Int
    
    @ScaledMetric private var scale = 1.0
    
    var body: some View {
        let count = TextCharacterCounter.numberOfCharacters(text)
        let color = isValid(count: count) ? Color.FG_2 : Color.red
        Text("\(Text(count.formatted()).foregroundStyle(color))/\(maxCount.formatted())")
            .font(.system(size: 12 * scale))
            .monospaced()
            .foregroundStyle(.FG_2)
    }
    
    private func isValid(count: Int) -> Bool {
        let minCountValid = minCount.map { count >= $0 } ?? true
        let maxCountValid = count <= maxCount
        return minCountValid && maxCountValid
    }
}

#Preview {
    CharacterCounterView(text: "🙋🏻‍♀️", maxCount: 10)
}
