import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject private var appVM: AppViewModel

    private let primary = Color.primaryPurple
    private let accent  = Color.accentCyan
    
    let primaryBrand = Color(red: 0.75, green: 0.70, blue: 0.90)
    let accentBrand = Color(red: 0.55, green: 0.75, blue: 0.80)
    let loaderColor = Color(red: 0.55, green: 0.50, blue: 0.80)
    let whiteColor = Color.white.opacity(0.85)

    @State private var checkScale: CGFloat = 0.70
    @State private var checkOpacity: Double = 0.0
    @State private var ringRotation: Angle = .degrees(0)
    @State private var ringTrim: CGFloat = 1

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    primaryBrand.opacity(0.5),
                    accentBrand.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                ZStack {
                    // Soft glow
                    Circle()
                        .fill(whiteColor.opacity(0.20))
                        .frame(width: 140, height: 140)
                        .blur(radius: 10)

                    // Progress ring (animated)
                    Circle()
                        .trim(from: 0, to: ringTrim)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [loaderColor, whiteColor,loaderColor]),
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
                        .foregroundStyle(loaderColor)
                        .scaleEffect(checkScale)
                        .opacity(checkOpacity)
                        .shadow(color: primary.opacity(0.5), radius: 14, x: 0, y: 6)
                }

                Text("HabitFlow")
                    .font(.system(size: 54, design: .rounded).weight(.heavy))
                    .foregroundStyle(loaderColor)
            }
            .padding(.horizontal)
        }
        .onAppear {
            // Logo pop-in
            withAnimation(.easeOut(duration: 1)) {
                checkOpacity = 1.0
                checkScale = 1.0
            }

            // Ring motion
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                ringRotation = .degrees(360)
            }
            withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                ringTrim = 0.2
            }

            // Auto transition after 2.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.75) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    appVM.dismissLaunchScreen()
                }
            }
        }
        .dynamicTypeSize(.small ... .accessibility3)
    }
}
