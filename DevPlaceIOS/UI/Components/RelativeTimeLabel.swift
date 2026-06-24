import SwiftUI

struct RelativeTimeLabel: View {
    let date: Date
    
    var body: some View {
        Text(date, format: .relative(presentation: .named, unitsStyle: .narrow))
            .font(.subheadline)
            .foregroundStyle(Color.FG_2)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        RelativeTimeLabel(date: Date().addingTimeInterval(-30))
        RelativeTimeLabel(date: Date().addingTimeInterval(-60 * 13))
        RelativeTimeLabel(date: Date().addingTimeInterval(-60 * 60 * 2))
        RelativeTimeLabel(date: Date().addingTimeInterval(-60 * 60 * 24))
        RelativeTimeLabel(date: Date().addingTimeInterval(-60 * 60 * 24 * 7))
    }
    .padding()
}
