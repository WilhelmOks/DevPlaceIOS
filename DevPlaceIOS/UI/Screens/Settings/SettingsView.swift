//
//  SettingsView.swift
//  DevPlaceIOS
//
//  Created by Wilhelm Oks on 22.06.26.
//

import SwiftUI

struct SettingsView: View {
    enum FullscreenNavigationItem: Identifiable {
        case signIn
        
        var id: Self { self }
    }
    
    @State var fullscreenNavigationItem: FullscreenNavigationItem?
    
    var body: some View {
        NavigationStack {
            content()
                .background {
                    Color.BG_2.ignoresSafeArea()
                }
                //.foregroundStyle(.FG_1)
                .navigationTitle(Text("Settings"))
                .toolbar {
                    if true {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Sign in") {
                                fullscreenNavigationItem = .signIn
                            }
                            .buttonStyle(.glassProminent)
                        }
                    }
                }
                .fullScreenCover(item: $fullscreenNavigationItem) { item in
                    switch item {
                    case .signIn:
                        LogInView()
                    }
                }
        }
    }
    
    @ViewBuilder private func content() -> some View {
        Form {
            Section {
                if true {
                    Button("Sign out") {
                        
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    SettingsView()
}
