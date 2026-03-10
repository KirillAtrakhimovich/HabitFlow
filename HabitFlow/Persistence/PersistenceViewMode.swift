import Foundation
import SwiftUI
import CoreData

@MainActor
final class PersistenceViewModel: ObservableObject {
    // Храним Core Data объекты напрямую
    @Published var habits: [HabitCD] = []
    
    private let context = PersistenceController.shared.container.viewContext
    
    @Published private(set) var completedToday: Set<UUID> = []
    
    init() {
        fetchHabits()
        
        // Если база пустая - создаем тестовые данные
        if habits.isEmpty {
            createSampleHabits()
        }
    }
    
    // MARK: - Core Data Operations
    
    func fetchHabits() {
        let request: NSFetchRequest<HabitCD> = HabitCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitCD.createdAt, ascending: true)]
        
        do {
            habits = try context.fetch(request)
            updateCompletedToday() // Обновляем список выполненных на сегодня
        } catch {
            print("Ошибка загрузки: \(error)")
        }
    }
    
    func createSampleHabits() {
        let samples = ["Вода", "Тренировка", "Чтение"]
        
        for sample in samples {
            let habit = HabitCD(context: context)
            habit.id = UUID()
            habit.title = sample
            habit.createdAt = Date()
            habit.colorName = "systemBlue"
            habit.iconName = "drop.fill"
        }
        
        saveContext()
        fetchHabits()
    }
    
    func addHabit(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let habit = HabitCD(context: context)
        habit.id = UUID()
        habit.title = trimmedTitle
        habit.createdAt = Date()
        habit.colorName = "systemBlue"
        habit.iconName = "drop.fill"
        
        saveContext()
        fetchHabits()
    }
    
    func toggleHabit(_ habit: HabitCD) {
        // Определяем текущее состояние на основе completedToday
        let isCurrentlyCompleted = completedToday.contains(habit.id)
        
        // Обновляем completedDates для истории
        var dates = habit.completedDates ?? []
        let today = Calendar.current.startOfDay(for: Date())
        
        if !isCurrentlyCompleted {
            // Если не выполнено - добавляем сегодня
            if !dates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                dates.append(today)
            }
        } else {
            // Если выполнено - убираем сегодня
            dates.removeAll { Calendar.current.isDate($0, inSameDayAs: today) }
        }
        
        habit.completedDates = dates
        saveContext()
        
        // Обновляем completedToday
        if !isCurrentlyCompleted {
            completedToday.insert(habit.id)
        } else {
            completedToday.remove(habit.id)
        }
        
        // Уведомляем UI об изменениях
        objectWillChange.send()
    }
    
    func deleteHabit(_ habit: HabitCD) {
        context.delete(habit)
        saveContext()
        completedToday.remove(habit.id)
        fetchHabits()
    }
    
    // MARK: - Helper Methods
    
    private func updateCompletedToday() {
        completedToday.removeAll()
        let today = Calendar.current.startOfDay(for: Date())
        
        for habit in habits {
            if let completedDates = habit.completedDates,
               completedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                completedToday.insert(habit.id)
            }
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
    
    // MARK: - Convenience Methods
    
    func isCompletedToday(_ habit: HabitCD) -> Bool {
        completedToday.contains(habit.id)
    }
    
    var completedCount: Int {
        completedToday.count
    }
    
    var totalCount: Int {
        habits.count
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}
