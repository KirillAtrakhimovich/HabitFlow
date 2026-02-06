import Foundation
import SwiftUI

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []

    // In-memory progress for "today" (simple starter approach).
    // Later you can replace with persistence + DailyRecord storage.
    @Published private(set) var completedToday: Set<UUID> = []

    private var today: DateOnly { DateOnly(date: Date()) }

    func loadHabits() {
        // Starter seed (remove when you add persistence)
        if !habits.isEmpty { return }

        habits = [
            Habit(
                title: "Вода",
                iconName: "drop.fill",
                colorHex: "00FFFF",
                goalTimesPerWeek: 7,
                reminderTime: DateComponents(hour: 10, minute: 0)
            ),
            Habit(
                title: "Тренировка",
                iconName: "figure.strengthtraining.traditional",
                colorHex: "8A2BE2",
                goalTimesPerWeek: 3,
                reminderTime: DateComponents(hour: 19, minute: 30)
            ),
            Habit(
                title: "Чтение",
                iconName: "book.fill",
                colorHex: "34C759",
                goalTimesPerWeek: 5,
                reminderTime: DateComponents(hour: 21, minute: 0)
            )
        ]

        // reset today's completion (naive; replace with DailyRecord later)
        completedToday.removeAll()
        _ = today
    }

    func toggleHabit(_ habit: Habit) {
        if completedToday.contains(habit.id) {
            completedToday.remove(habit.id)
        } else {
            completedToday.insert(habit.id)
        }
    }

    func addHabit(
        title: String,
        iconName: String = "sparkles",
        colorHex: String = "8A2BE2",
        goalTimesPerWeek: Int = 7,
        reminderTime: DateComponents? = nil
    ) {
        let newHabit = Habit(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            iconName: iconName,
            colorHex: colorHex,
            goalTimesPerWeek: goalTimesPerWeek,
            reminderTime: reminderTime
        )
        guard !newHabit.title.isEmpty else { return }
        habits.insert(newHabit, at: 0)
    }

    // MARK: - New methods for HabitDetailView
    
    func updateHabit(_ updatedHabit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) {
            habits[index] = updatedHabit
        }
    }

    func archiveHabit(_ id: UUID) {
        habits.removeAll { $0.id == id }
        completedToday.remove(id)
    }

    func deleteHabit(_ id: UUID) {
        habits.removeAll { $0.id == id }
        completedToday.remove(id)
    }

    // Convenience
    func isCompletedToday(_ habit: Habit) -> Bool {
        completedToday.contains(habit.id)
    }

    var completedCount: Int { completedToday.count }
    var totalCount: Int { habits.count }
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}
