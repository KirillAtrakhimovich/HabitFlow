//
//  HabitRepository.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import Foundation
import CoreData
import UIKit
import Combine

@MainActor
final class HabitRepository: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    
    private let context = PersistenceController.shared.container.viewContext
    private let lastResetDateKey = "lastResetDate"
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    init() {
        print("📅 HabitRepository инициализирован")
        setupNotifications()
        checkForNewDay()
        fetchHabits()
    }
    
    // MARK: - Настройка наблюдателей
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                print("📱 Приложение вернулось из фона")
                self?.checkForNewDay()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)
            .sink { [weak self] _ in
                print("⏰ Значительное изменение времени")
                self?.checkForNewDay()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Проверка смены дня
    func checkForNewDay() {
        let lastReset = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date ?? Date.distantPast
        
        print("📅 Последний сброс был: \(lastReset)")
        print("📅 Сегодня: \(Date())")
        
        if !calendar.isDateInToday(lastReset) {
            print("🔄 Наступил новый день! Сбрасываем привычки...")
            resetCompletedHabits()
            UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
        } else {
            print("✅ Сегодня уже сбрасывали, пропускаем")
        }
    }
    
    // MARK: - Сброс выполненных привычек
    private func resetCompletedHabits() {
        let request: NSFetchRequest<HabitCD> = HabitCD.fetchRequest()
        
        do {
            let cdHabits = try context.fetch(request)
            print("📊 Найдено привычек для сброса: \(cdHabits.count)")
            
            for cdHabit in cdHabits {
                let completedDates = cdHabit.completedDates ?? []
                let previousDates = completedDates.filter { date in
                    !calendar.isDateInToday(date)
                }
                
                if completedDates.count != previousDates.count {
                    print("  • Привычка '\(cdHabit.title)': сброшена")
                    cdHabit.completedDates = previousDates
                }
            }
            
            saveContext()
            print("💾 Сброс завершен")
            fetchHabits()
            
        } catch {
            print("❌ Ошибка при сбросе привычек: \(error)")
        }
    }
    
    // MARK: - CRUD операции
    func fetchHabits() {
        let request: NSFetchRequest<HabitCD> = HabitCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitCD.createdAt, ascending: true)]
        
        do {
            let cdHabits = try context.fetch(request)
            habits = cdHabits.map { Habit(from: $0) }
            print("📋 Загружено привычек: \(habits.count)")
        } catch {
            print("Ошибка загрузки: \(error)")
        }
    }
    
    func addHabit(title: String, icon: String = "sparkles", colorName: String = "Фиолетовый") {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let habit = HabitCD(context: context)
        habit.id = UUID()
        habit.title = trimmedTitle
        habit.createdAt = Date()
        habit.iconName = icon
        habit.colorName = colorName
        habit.completedDates = []
        
        saveContext()
        fetchHabits()
    }
    
    func updateHabit(_ habit: Habit, title: String? = nil, icon: String? = nil, colorName: String? = nil) {
        let request: NSFetchRequest<HabitCD> = HabitCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            guard let cdHabit = results.first else { return }
            
            if let title = title, !title.isEmpty {
                cdHabit.title = title
            }
            
            if let icon = icon {
                cdHabit.iconName = icon
            }
            
            if let colorName = colorName {
                cdHabit.colorName = colorName
            }
            
            saveContext()
            fetchHabits()
            print("✏️ Привычка '\(habit.title)' обновлена")
        } catch {
            print("Ошибка при обновлении: \(error)")
        }
    }
    
    func toggleHabit(_ habit: Habit) {
        let request: NSFetchRequest<HabitCD> = HabitCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            guard let cdHabit = results.first else { return }
            
            var dates = cdHabit.completedDates ?? []
            let today = Date()
            
            if habit.isCompletedToday {
                dates.removeAll { calendar.isDate($0, inSameDayAs: today) }
                print("  • Убираем отметку с '\(habit.title)'")
            } else {
                if !dates.contains(where: { calendar.isDate($0, inSameDayAs: today) }) {
                    dates.append(today)
                    print("  • Отмечаем '\(habit.title)' как выполненную")
                }
            }
            
            cdHabit.completedDates = dates
            saveContext()
            fetchHabits()
            
        } catch {
            print("Ошибка при toggle: \(error)")
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        let request: NSFetchRequest<HabitCD> = HabitCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let cdHabit = results.first {
                context.delete(cdHabit)
                saveContext()
                fetchHabits()
                print("🗑 Привычка '\(habit.title)' удалена")
            }
        } catch {
            print("Ошибка при удалении: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
    
    // MARK: - Вспомогательные свойства
    var completedCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    var totalCount: Int {
        habits.count
    }
    
    var progress: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }
}
