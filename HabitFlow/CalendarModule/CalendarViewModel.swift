//
//  CalendarViewModel.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import SwiftUI
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var monthOffset: Int = 0
    @Published private(set) var selectedDate: DateOnly
    @Published private(set) var completionByDay: [DateOnly: Double] = [:]
    @Published private(set) var hasAnyCompletion: Set<DateOnly> = []
    
    // MARK: - Dependencies
    private let calendar: Calendar
    private let repository: HabitRepositoryProtocol?
    
    // MARK: - Init
    init(calendar: Calendar = {
        var c = Calendar.current
        c.firstWeekday = 2 // Monday
        return c
    }(), repository: HabitRepositoryProtocol? = nil) {
        self.calendar = calendar
        self.repository = repository
        self.selectedDate = DateOnly(date: Date(), calendar: calendar)
        
        loadDemoDataIfNeeded()
    }
    
    // MARK: - Computed Properties
    var displayedMonthDate: Date {
        let base = Date()
        return calendar.date(byAdding: .month, value: monthOffset, to: base) ?? base
    }
    
    var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        return f.string(from: displayedMonthDate).capitalized
    }
    
    var monthGridDays: [DateOnly] {
        let monthStart = startOfMonth(displayedMonthDate)
        let firstWeekdayIndex = weekdayIndexMondayFirst(monthStart)
        let gridStart = calendar.date(byAdding: .day, value: -firstWeekdayIndex, to: monthStart) ?? monthStart
        
        return (0..<42).compactMap { i in
            guard let d = calendar.date(byAdding: .day, value: i, to: gridStart) else { return nil }
            return DateOnly(date: d, calendar: calendar)
        }
    }
    
    var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return Array(symbols[1...6]) + [symbols[0]]
    }
    
    var selectedDateFormatted: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateStyle = .full
        return f.string(from: selectedDate.toDate(calendar: calendar))
    }
    
    var selectedDayCompletion: Double {
        completionByDay[selectedDate] ?? 0
    }
    
    var selectedDayCompletionPercent: Int {
        Int(selectedDayCompletion * 100)
    }
    
    var weeklyValues: [Double] {
        let endDate = selectedDate.toDate(calendar: calendar)
        return (0..<7).map { i in
            let dayDate = calendar.date(byAdding: .day, value: i - 6, to: endDate) ?? endDate
            let key = DateOnly(date: dayDate, calendar: calendar)
            return min(1, max(0, completionByDay[key] ?? 0))
        }
    }
    
    var weeklyAverage: Double {
        guard !weeklyValues.isEmpty else { return 0 }
        return weeklyValues.reduce(0, +) / Double(weeklyValues.count)
    }
    
    var weeklyAveragePercent: Int {
        Int(weeklyAverage * 100)
    }
    
    var monthCompletionPercent: Double {
        let days = monthGridDays.filter(isInDisplayedMonth)
        let values = days.compactMap { completionByDay[$0] }.map { min(1, max(0, $0)) }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
    
    var monthCompletionPercentInt: Int {
        Int(monthCompletionPercent * 100)
    }
    
    // MARK: - Public Methods
    func previousMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            monthOffset -= 1
        }
    }
    
    func nextMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            monthOffset += 1
        }
    }
    
    func selectDate(_ date: DateOnly) {
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedDate = date
        }
    }
    
    func isInDisplayedMonth(_ day: DateOnly) -> Bool {
        let month = calendar.component(.month, from: displayedMonthDate)
        let year = calendar.component(.year, from: displayedMonthDate)
        return day.month == month && day.year == year
    }
    
    func hasCompletion(_ day: DateOnly) -> Bool {
        hasAnyCompletion.contains(day)
    }
    
    // MARK: - Private Methods
    private func startOfMonth(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }
    
    private func weekdayIndexMondayFirst(_ date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return (weekday + 5) % 7
    }
    
    // MARK: - Data Loading
    private func loadDemoDataIfNeeded() {
        guard completionByDay.isEmpty else { return }
        
        let base = Date()
        for i in 0..<60 {
            guard let d = calendar.date(byAdding: .day, value: -i, to: base) else { continue }
            let key = DateOnly(date: d, calendar: calendar)
            
            let r = Double((key.day * 37 + key.month * 13) % 101) / 100.0
            let value = max(0, min(1, (r - 0.15) / 0.85))
            
            completionByDay[key] = value
            if value >= 0.33 {
                hasAnyCompletion.insert(key)
            }
        }
    }
    
    // Для реальных данных из репозитория
    func loadRealData(from habits: [Habit]) {
        // Очищаем текущие данные
        completionByDay.removeAll()
        hasAnyCompletion.removeAll()
        
        // Группируем выполнения по дням
        for habit in habits {
            for date in habit.completedDates {
                let dateOnly = DateOnly(date: date, calendar: calendar)
                
                // Обновляем процент выполнения для дня
                let currentValue = completionByDay[dateOnly] ?? 0
                let totalHabits = habits.count
                let newValue = currentValue + (1.0 / Double(totalHabits))
                completionByDay[dateOnly] = min(1, newValue)
                
                // Добавляем в множество дней с выполнениями
                hasAnyCompletion.insert(dateOnly)
            }
        }
    }
}
