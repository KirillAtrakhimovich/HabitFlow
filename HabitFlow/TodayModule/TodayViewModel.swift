import SwiftUI
import CoreData

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var habits: [HabitCD] = []
    @Published private(set) var completedToday: Set<UUID> = []
    @Published var showAddSheet = false
    @Published var newHabitTitle = ""
    
    private let persistenceVM: PersistenceViewModel
    
    init() {
        self.persistenceVM = PersistenceViewModel()
        self.habits = persistenceVM.habits
        self.completedToday = persistenceVM.completedToday
    }
    
    // MARK: - Computed Properties
    var completedCount: Int {
        persistenceVM.completedCount
    }
    
    var totalCount: Int {
        persistenceVM.totalCount
    }
    
    var progress: Double {
        persistenceVM.progress
    }
    
    var hasHabits: Bool {
        !habits.isEmpty
    }
    
    var isAddButtonDisabled: Bool {
        newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Methods
    func isCompletedToday(_ habit: HabitCD) -> Bool {
        persistenceVM.isCompletedToday(habit)
    }
    
    func toggleHabit(_ habit: HabitCD) {
        persistenceVM.toggleHabit(habit)
        updateFromPersistence()
    }
    
    func addHabit() {
        persistenceVM.addHabit(title: newHabitTitle)
        newHabitTitle = ""
        showAddSheet = false
        updateFromPersistence()
    }
    
    func refresh() {
        updateFromPersistence()
    }
    
    private func updateFromPersistence() {
        habits = persistenceVM.habits
        completedToday = persistenceVM.completedToday
    }
    
    // MARK: - Formatting
    func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
}
