import SwiftUI

@main
struct HabitFlowApp: App {
    @StateObject private var appVM = AppViewModel()

    private let primaryColor = Color.primaryPurple
    private let accentColor  = Color.accentCyan
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                if appVM.showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                } else if appVM.showOnboarding {
                    OnboardingView()
                        .transition(.opacity)
                } else {
                    RootView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: appVM.showLaunchScreen)
            .animation(.easeInOut(duration: 0.25), value: appVM.showOnboarding)
            .environmentObject(appVM)
            .tint(accentColor)
            .environment(\.colorScheme, .light)
            .environment(\.font, .system(.body, design: .rounded))

        }
    }
}

// MARK: - AppViewModel

@MainActor
final class AppViewModel: ObservableObject {
    @Published var showLaunchScreen: Bool = true
    @Published var showOnboarding: Bool = true

    func completeOnboarding() {
        showOnboarding = false
    }

    func dismissLaunchScreen() {
        showLaunchScreen = false
    }
}

