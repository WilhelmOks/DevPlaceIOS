import SwiftUI
import DevPlaceSwiftSDK

struct UserImage: View {
    let user: User
    
    @ScaledMetric private var scale = 1
    
    var body: some View {
        let urlString = "https://devplace.net/avatar/multiavatar/\(user.username)"
        
        AsyncSVGImage(url: URL(string: urlString)) { image in
            image.resizable()
        } placeholder: {
            ZStack {
                Circle()
                    .foregroundStyle(Color.BG_1)
                
                ProgressView()
            }
        }
        .frame(width: 42 * scale, height: 42 * scale)
    }
}

#Preview {
    VStack(spacing: 10) {
        UserImage(user: .mock)
        UserImage(user: .mock2)
    }
    .padding()
}
