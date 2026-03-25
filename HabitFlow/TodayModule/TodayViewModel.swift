import SwiftUI

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    @Published var showAddSheet = false
    @Published var newHabitTitle = ""
    
    private let repository: HabitRepository
    
    init() {
        self.repository = HabitRepository()
        self.habits = repository.habits
        
        // Подписываемся на изменения в репозитории
        setupBindings()
    }
    
    private func setupBindings() {
        // Можно использовать Combine или просто обновлять при каждом действии
    }
    
    // MARK: - Computed Properties
    var completedCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    var totalCount: Int {
        habits.count
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var hasHabits: Bool {
        !habits.isEmpty
    }
    
    var isAddButtonDisabled: Bool {
        newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Methods
    func loadHabits() {
        habits = repository.habits
    }
    
    func toggleHabit(_ habit: Habit) {
        repository.toggleHabit(habit)
        loadHabits() // Обновляем список после изменения
    }
    
    func editHabit(_ habit: Habit) {
           // Логика редактирования
           print("Редактирование: \(habit.title)")
       }

    
    func addHabit() {
        repository.addHabit(title: newHabitTitle)
        newHabitTitle = ""
        showAddSheet = false
        loadHabits()
    }
    
    func deleteHabit(_ habit: Habit) {
        repository.deleteHabit(habit)
        loadHabits()
    }
    
    func refresh() {
        repository.fetchHabits()
        loadHabits()
    }
    
    // MARK: - Formatting
    func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
}
