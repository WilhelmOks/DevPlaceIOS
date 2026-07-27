import SwiftUI

struct CharacterCounterView: View {
    let text: String
    let maxCount: Int
    
    @ScaledMetric private var scale = 1.0
    
    var body: some View {
        let count = TextCharacterCounter.numberOfCharacters(text)
        let color = count > maxCount ? Color.red : Color.FG_2
        Text("\(Text(count.formatted()).foregroundStyle(color))/\(maxCount.formatted())")
            .font(.system(size: 12 * scale))
            .monospaced()
            .foregroundStyle(.FG_2)
    }
}

#Preview {
    CharacterCounterView(text: "🙋🏻‍♀️", maxCount: 10)
}
