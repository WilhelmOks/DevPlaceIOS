import SwiftUI

struct RelativeTimeLabel: View {
    let date: Date
    
    @ScaledMetric private var scale = 1.0
    
    var body: some View {
        Text(date, format: .relative(presentation: .named, unitsStyle: .narrow))
            .font(.system(size: 12 * scale))
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
