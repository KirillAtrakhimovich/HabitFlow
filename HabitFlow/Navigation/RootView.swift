import SwiftUI

struct RootView: View {
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
    private let primary = Color.primaryPurple
    private let accent = Color.accentCyan
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
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
            .tint(.blue.opacity(0.7))
        }
        .dynamicTypeSize(.small ... .accessibility3)
    }
}
