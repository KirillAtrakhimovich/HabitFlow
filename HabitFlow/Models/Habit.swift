import Foundation

struct Habit: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var iconName: String
    var colorHex: String
    var goalTimesPerWeek: Int
    /// Time-only reminder (e.g., 09:30). Use `nil` for no reminder.
    var reminderTime: DateComponents?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        iconName: String,
        colorHex: String,
        goalTimesPerWeek: Int,
        reminderTime: DateComponents? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.colorHex = colorHex
        self.goalTimesPerWeek = goalTimesPerWeek
        self.reminderTime = reminderTime
        self.createdAt = createdAt
    }
}
