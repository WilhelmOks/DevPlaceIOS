import SwiftUI
import DevPlaceSwiftSDK

struct UserImage: View {
    let user: User
    var size: Size = .normal
    
    @ScaledMetric private var scale = 1
    
    var body: some View {
        let seed = user.avatarSeed ?? user.username
        let urlString = "https://devplace.net/avatar/multiavatar/\(seed)"
        
        AsyncSVGImage(url: URL(string: urlString)) { image in
            image.resizable()
        } placeholder: {
            ZStack {
                Circle()
                    .foregroundStyle(Color.BG_1)
                
                ProgressView()
            }
        }
        .frame(width: size.points * scale, height: size.points * scale)
    }
}

extension UserImage {
    enum Size {
        case normal
        case large
        
        var points: CGFloat {
            switch self {
            case .normal: 42
            case .large: 100
            }
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        UserImage(user: .mock)
        UserImage(user: .mock2)
        UserImage(user: .mock2, size: .large)
    }
    .padding()
}
