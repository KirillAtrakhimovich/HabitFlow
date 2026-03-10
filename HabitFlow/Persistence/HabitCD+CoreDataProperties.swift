public import Foundation
public import CoreData

extension HabitCD {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitCD> {
        return NSFetchRequest<HabitCD>(entityName: "HabitCD")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var iconName: String
    @NSManaged public var colorName: String
    @NSManaged public var createdAt: Date
    @NSManaged public var completedDates: [Date]?
    
}
