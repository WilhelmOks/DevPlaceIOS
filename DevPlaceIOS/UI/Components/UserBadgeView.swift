import SwiftUI
import DevPlaceSwiftSDK

struct UserBadgeView: View {
    let badge: Badge
    
    @ScaledMetric private var scale = 1.0
    
    var body: some View {
        if let name = badge.name {
            Text(name)
                .foregroundStyle(.accent)
                .font(.system(size: 12 * scale, weight: .semibold))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background {
                    Capsule()
                        .foregroundStyle(.accent.opacity(0.2))
                }
        }
    }
}

#Preview {
    VStack {
        ForEach([Badge].mock, id: \.self) { badge in
            UserBadgeView(badge: badge)
        }
    }
}
