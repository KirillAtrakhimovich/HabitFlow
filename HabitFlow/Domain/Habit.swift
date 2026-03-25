import Foundation
import SwiftUI

struct Habit: Identifiable, Hashable {
    let id: UUID
    let title: String
    let createdAt: Date
    let colorName: String
    let iconName: String
    let completedDates: [Date]
    
    // MARK: - Computed Properties
    
    // Конвертируем имя цвета в SwiftUI Color
    var color: Color {
        switch colorName {
        case "Фиолетовый":
            return Color(hex: "8A2BE2") ?? .purple
        case "Голубой":
            return Color(hex: "00FFFF") ?? .cyan
        case "Зелёный":
            return Color(hex: "34C759") ?? .green
        case "Оранжевый":
            return Color(hex: "FF9500") ?? .orange
        case "Красный":
            return Color(hex: "FF3B30") ?? .red
        case "Синий":
            return Color(hex: "007AFF") ?? .blue
        case "Розовый":
            return Color(hex: "FF2D55") ?? .pink
        case "Пурпурный":
            return Color(hex: "AF52DE") ?? .purple
        case "Жёлтый":
            return Color(hex: "FFCC00") ?? .yellow
        case "Светло-синий":
            return Color(hex: "5AC8FA") ?? .cyan
        default:
            return .purple // fallback
        }
    }
    
    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return completedDates.contains { Calendar.current.isDate($0, inSameDayAs: today) }
    }
    
    var streakCount: Int {
        // Логика подсчета streak
        var streak = 0
        let calendar = Calendar.current
        let sortedDates = completedDates.sorted().reversed()
        
        var currentDate = calendar.startOfDay(for: Date())
        
        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    // Инициализатор из Core Data модели
    init(from cdModel: HabitCD) {
        self.id = cdModel.id
        self.title = cdModel.title
        self.createdAt = cdModel.createdAt
        self.colorName = cdModel.colorName
        self.iconName = cdModel.iconName
        self.completedDates = cdModel.completedDates ?? []
    }
    
    // Инициализатор для создания новой привычки
    init(id: UUID = UUID(), title: String, iconName: String, colorName: String, createdAt: Date = Date(), completedDates: [Date] = []) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.colorName = colorName
        self.createdAt = createdAt
        self.completedDates = completedDates
    }
}
