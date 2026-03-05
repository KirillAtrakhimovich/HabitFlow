//
//  HabitCD+CoreDataProperties.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 18.02.26.
//
//

public import Foundation
public import CoreData


public typealias HabitCDCoreDataPropertiesSet = NSSet

extension HabitCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitCD> {
        return NSFetchRequest<HabitCD>(entityName: "HabitCD")
    }

    @NSManaged public var isCompleted: Bool
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var completedDates: [Date]?
    @NSManaged public var createdAt: Date

}

extension HabitCD : Identifiable {

}
