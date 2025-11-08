import SwiftUI

/// Banner that appears when the device is offline
struct OfflineBanner: View {
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var isVisible = false
    
    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("No Internet Connection")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("You're offline. Some features may be limited.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.orange)
            .offset(y: isVisible ? 0 : -100)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isVisible)
            .onAppear {
                withAnimation {
                    isVisible = true
                }
            }
        }
    }
}

/// Modifier to add offline banner to any view
struct OfflineBannerModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            OfflineBanner()
            content
        }
    }
}

extension View {
    func offlineBanner() -> some View {
        modifier(OfflineBannerModifier())
    }
}

#Preview {
    VStack {
        OfflineBanner()
        Spacer()
    }
}
