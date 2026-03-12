//
//  HabitRepository.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import Foundation
import CoreData

@MainActor
final class HabitRepository: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    
    private let context = PersistenceController.shared.container.viewContext
    
    init() {
        fetchHabits()
    }
    
    func fetchHabits() {
        let request: NSFetchRequest<HabitCD> = HabitCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitCD.createdAt, ascending: true)]
        
        do {
            let cdHabits = try context.fetch(request)
            habits = cdHabits.map { Habit(from: $0) }
        } catch {
            print("Ошибка загрузки: \(error)")
        }
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
        habit.completedDates = []
        
        saveContext()
        fetchHabits()
    }
    
    func toggleHabit(_ habit: Habit) {
        // Находим соответствующий CD объект
        let request: NSFetchRequest<HabitCD> = HabitCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            guard let cdHabit = results.first else { return }
            
            // Обновляем completedDates
            var dates = cdHabit.completedDates ?? []
            let today = Calendar.current.startOfDay(for: Date())
            
            if habit.isCompletedToday {
                dates.removeAll { Calendar.current.isDate($0, inSameDayAs: today) }
            } else {
                if !dates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                    dates.append(today)
                }
            }
            
            cdHabit.setValue(dates, forKey: "completedDates")
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
}
