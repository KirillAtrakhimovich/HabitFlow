import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject private var appVM: AppViewModel

    private let primary = Color.primaryPurple
    private let accent  = Color.accentCyan

    @State private var checkScale: CGFloat = 0.70
    @State private var checkOpacity: Double = 0.0
    @State private var ringRotation: Angle = .degrees(0)
    @State private var ringTrim: CGFloat = 0.15

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    primary.opacity(0.22),
                    Color.black.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                ZStack {
                    // Soft glow
                    Circle()
                        .fill(primary.opacity(0.20))
                        .frame(width: 140, height: 140)
                        .blur(radius: 10)

                    // Progress ring (animated)
                    Circle()
                        .trim(from: 0, to: ringTrim)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [accent, primary, accent]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 128, height: 128)
                        .rotationEffect(ringRotation)
                        .shadow(color: accent.opacity(0.25), radius: 10, x: 0, y: 0)

                    // Checkmark logo
                    Image(systemName: "checkmark")
                        .font(.system(size: 54, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .scaleEffect(checkScale)
                        .opacity(checkOpacity)
                        .shadow(color: primary.opacity(0.5), radius: 14, x: 0, y: 6)
                }

                Text("HabitFlow")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(.white.opacity(0.95))

                // Spinner fallback (small, subtle)
                ProgressView()
                    .tint(accent)
                    .scaleEffect(1.05)
                    .opacity(0.9)
            }
            .padding(.horizontal)
        }
        .onAppear {
            // Logo pop-in
            withAnimation(.easeOut(duration: 0.55)) {
                checkOpacity = 1.0
                checkScale = 1.0
            }

            // Ring motion
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                ringRotation = .degrees(360)
            }
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                ringTrim = 0.75
            }

            // Auto transition after 2.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    appVM.dismissLaunchScreen()
                }
            }
        }
        .dynamicTypeSize(.small ... .accessibility3)
    }
}
