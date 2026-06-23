import SwiftUI
import DevPlaceSwiftSDK

struct TemplateView: View {
    @Environment(\.api) var api
    
    var body: some View {
        TemplateViewContent(viewModel: .init(api: api))
    }
}

private struct TemplateViewContent: View {
    @State var viewModel: TemplateView.ViewModel
    
    var body: some View {
        content()
    }
    
    @ViewBuilder private func content() -> some View {
        
    }
}

#Preview {
    TemplateView()
}
