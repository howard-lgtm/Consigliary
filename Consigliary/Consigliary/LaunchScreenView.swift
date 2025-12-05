import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var showApp = false
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Use the actual app icon
                Image("LaunchIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(26) // iOS app icon corner radius
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // App name
                Text("Consigliary")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Launch Screen C Shapes
struct LeftCLaunchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2.2
        let thickness = radius * 0.25
        let gapAngle: CGFloat = 25
        
        // Left C - gap at TOP
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(-90 + gapAngle),
            endAngle: .degrees(-90 - gapAngle + 360),
            clockwise: false
        )
        
        path.addArc(
            center: center,
            radius: radius - thickness,
            startAngle: .degrees(-90 - gapAngle + 360),
            endAngle: .degrees(-90 + gapAngle),
            clockwise: true
        )
        
        path.closeSubpath()
        return path
    }
}

struct RightCLaunchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2.2
        let thickness = radius * 0.25
        let gapAngle: CGFloat = 25
        
        // Right C - gap at BOTTOM
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(90 + gapAngle),
            endAngle: .degrees(90 - gapAngle + 360),
            clockwise: false
        )
        
        path.addArc(
            center: center,
            radius: radius - thickness,
            startAngle: .degrees(90 - gapAngle + 360),
            endAngle: .degrees(90 + gapAngle),
            clockwise: true
        )
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    LaunchScreenView()
}
