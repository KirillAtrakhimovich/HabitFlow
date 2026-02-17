import SwiftUI

struct RootView: View {
    // MARK: - Tabs
    enum Tab: String, CaseIterable {
        case today = "Today"
        case calendar = "Calendar"
        case add = "Add"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .today: return "checkmark.circle"
            case .calendar: return "calendar"
            case .add: return "plus.circle.fill"
            case .settings: return "gearshape"
            }
        }
    }
    
    @State private var selectedTab: Tab = .today
    
    // Theme
    private let primary = Color.primaryPurple
    private let accent = Color.accentCyan
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background

            
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "checkmark.circle")
                    }
                    .tag(Tab.today)
                
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(Tab.calendar)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(Tab.settings)
            }
            .tint(accent)
        }
        .dynamicTypeSize(.small ... .accessibility3)
    }
    
    // MARK: - Helpers
    private func iconColor(for tab: Tab) -> Color {
        if tab == .add {
            return .white
        }
        return selectedTab == tab ? accent : .white.opacity(0.5)
    }
    
    private func textColor(for tab: Tab) -> Color {
        selectedTab == tab ? .white : .white.opacity(0.5)
    }
}
// MARK: - Custom Tab Bar

private struct CustomTabBar: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @Binding var selectedTab: RootView.Tab

    let primary: Color
    let accent: Color

    var body: some View {
        HStack(spacing: hSizeClass == .regular ? 32 : 24) {
            tabButton(
                icon: "checkmark.circle",
                title: "Today",
                tab: .today
            )

            tabButton(
                icon: "calendar",
                title: "Calendar",
                tab: .calendar
            )

            tabButton(
                icon: "plus.circle.fill",
                title: "Add",
                tab: .add,
                isProminent: true
            )

            tabButton(
                icon: "gearshape",
                title: "Settings",
                tab: .settings
            )
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            BlurView(style: .systemUltraThinMaterialDark)
                .background(Color.black.opacity(0.65))
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 4)
    }

    private func tabButton(
        icon: String,
        title: String,
        tab: RootView.Tab,
        isProminent: Bool = false
    ) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: isProminent ? 26 : 20, weight: .semibold, design: .rounded))
                    .symbolVariant(isSelected && !isProminent ? .fill : .none)
                    .foregroundStyle(tabIconStyle(isProminent: isProminent, isSelected: isSelected))
                Text(title)
                    .font(.system(.caption2, design: .rounded).weight(isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isProminent ? 4 : 0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func tabIconStyle(isProminent: Bool, isSelected: Bool) -> AnyShapeStyle {
        if isProminent {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [accent, primary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            return AnyShapeStyle(isSelected ? accent : Color.white.opacity(0.7))
        }
    }
}

// MARK: - Add Tab Placeholder

/// Вкладка «Add» как отдельный экран.
/// Сейчас показывает плейсхолдер; позже сюда можно перенести полноценный сценарий создания привычки.
private struct AddEntryPointView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 16) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.accentCyan)

                    Text("Добавление привычки")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)

                    Text("Скоро здесь будет отдельный экран для создания привычек.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Add")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Blur Helper

private struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

