//
//  HabitRepositoryProtocol.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 18.02.26.
//

import Foundation
import Combine

protocol HabitRepositoryProtocol {
    // Наблюдение за изменениями
    var habitsPublisher: Published<[Habit]>.Publisher { get }
    
    // CRUD операции
    func fetchHabits() async
    func addHabit(title: String, iconName: String, colorName: String) async throws
    func updateHabit(_ habit: Habit) async throws
    func deleteHabit(_ habit: Habit) async throws
    
    // Операции с выполнением
    func toggleHabit(_ habit: Habit) async throws
    func isHabitCompletedToday(_ habit: Habit) -> Bool
    
    // Статистика
    func getCompletedCount(for date: Date) -> Int
    func getOverallProgress() -> Double
}
