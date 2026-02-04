import Foundation

/// Date without time (calendar day), stored as year-month-day.
/// Helpful for habit tracking where time-of-day should not affect equality/grouping.
struct DateOnly: Codable, Hashable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    init(date: Date, calendar: Calendar = .current) {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        self.year = comps.year ?? 1970
        self.month = comps.month ?? 1
        self.day = comps.day ?? 1
    }

    func toDate(calendar: Calendar = .current) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        // Start of day in the given calendar/timezone
        return calendar.date(from: comps) ?? Date(timeIntervalSince1970: 0)
    }

    static func < (lhs: DateOnly, rhs: DateOnly) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        if lhs.month != rhs.month { return lhs.month < rhs.month }
        return lhs.day < rhs.day
    }
}

struct DailyRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var habitId: UUID
    var date: DateOnly
    var completedCount: Int
    /// Stored flag (can be derived from `completedCount`, but kept as requested).
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        habitId: UUID,
        date: DateOnly,
        completedCount: Int = 0,
        isCompleted: Bool? = nil
    ) {
        self.id = id
        self.habitId = habitId
        self.date = date
        self.completedCount = max(0, completedCount)
        self.isCompleted = isCompleted ?? (self.completedCount > 0)
    }

    mutating func setCompletedCount(_ newValue: Int) {
        completedCount = max(0, newValue)
        isCompleted = completedCount > 0
    }

    mutating func markCompleted() {
        if completedCount == 0 { completedCount = 1 }
        isCompleted = true
    }

    mutating func markIncomplete() {
        completedCount = 0
        isCompleted = false
    }
}
