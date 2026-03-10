import Foundation

struct Habit: Identifiable, Hashable {
    let id: UUID
    let title: String
    let createdAt: Date
    let colorName: String
    let iconName: String
    let completedDates: [Date]
    
    // Вычисляемые свойства
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
}
