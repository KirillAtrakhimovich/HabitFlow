import SwiftUI
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    @Published var showAddSheet = false
    @Published var showEditSheet = false  // ← добавляем
    @Published var newHabitTitle = ""
    @Published var selectedIcon = "sparkles"  // ← добавляем
    @Published var selectedColorName = "Фиолетовый"  // ← добавляем
    @Published var editingHabit: Habit?  // ← добавляем
    
    private let repository: HabitRepository
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.repository = HabitRepository()
        setupBindings()
        loadHabits()
    }
    
    private func setupBindings() {
        // Подписываемся на изменения в репозитории
        repository.$habits
            .receive(on: DispatchQueue.main)
            .sink { [weak self] habits in
                self?.habits = habits
            }
            .store(in: &cancellables)
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
    }
    
    func addHabit() {
        repository.addHabit(
            title: newHabitTitle,
            icon: selectedIcon,
            colorName: selectedColorName
        )
        resetForm()
        showAddSheet = false
    }
    
    func updateHabit() {
        guard let habit = editingHabit else { return }
        
        repository.updateHabit(
            habit,
            title: newHabitTitle,
            icon: selectedIcon,
            colorName: selectedColorName
        )
        
        resetForm()
        showEditSheet = false
        editingHabit = nil
    }
    
    func startEditing(_ habit: Habit) {
        newHabitTitle = habit.title
        selectedIcon = habit.iconName
        selectedColorName = habit.colorName
        editingHabit = habit
        showEditSheet = true
    }
    
    func deleteHabit(_ habit: Habit) {
        repository.deleteHabit(habit)
    }
    
    func resetForm() {
        newHabitTitle = ""
        selectedIcon = "sparkles"
        selectedColorName = "Фиолетовый"
        editingHabit = nil
    }
    
    func refresh() {
        repository.fetchHabits()
    }
    
    // MARK: - Formatting
    func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
}
