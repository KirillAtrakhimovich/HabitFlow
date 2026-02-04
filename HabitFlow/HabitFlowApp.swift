import SwiftUI

@main
struct HabitFlowApp: App {
    @StateObject private var appVM = AppViewModel()

    // App theme
    private let primaryColor = Color.purple
    private let accentColor  = Color.cyan

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main routing
                if appVM.showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                } else if appVM.showOnboarding {
                    // Replace with your real OnboardingView when you add it
                    OnboardingView()
                        .transition(.opacity)
                } else {
                    // Replace with your real Main/Tab view when you add it
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: appVM.showLaunchScreen)
            .animation(.easeInOut(duration: 0.25), value: appVM.showOnboarding)
            .environmentObject(appVM)
            .tint(accentColor)
            .environment(\.colorScheme, .light)
            .environment(\.font, .system(.body, design: .rounded))
            .onAppear {
                appVM.primaryColorHex = .purple
                appVM.accentColorHex = .cyan
            }
        }
    }
}

// MARK: - AppViewModel

@MainActor
final class AppViewModel: ObservableObject {
    @Published var showLaunchScreen: Bool = true
    @Published var showOnboarding: Bool = true

    // Optional: keep theme values accessible app-wide if needed later
    @Published var primaryColorHex: Color = .purple
    @Published var accentColorHex: Color = .cyan

    /// Call when onboarding is finished.
    func completeOnboarding() {
        showOnboarding = false
    }

    /// Called by the launch screen (or app) to dismiss it.
    func dismissLaunchScreen() {
        showLaunchScreen = false
    }
}

// MARK: - Temporary placeholders (remove when real views exist)

private struct PlaceholderOnboardingView: View {
    @EnvironmentObject private var appVM: AppViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Onboarding")
                .font(.system(.title, design: .rounded).weight(.bold))
            Text("Replace this with your real onboarding screens.")
                .foregroundStyle(.secondary)

            Button("Finish Onboarding") {
                appVM.completeOnboarding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

private struct PlaceholderMainView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("HabitFlow")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
            Text("Replace this with your main app UI.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Сегодня")
                       
                }
                .background(Color.purple)

            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Календарь")
                }
                .background(Color.purple)
        }
        .background(Color.purple)
    }
}
