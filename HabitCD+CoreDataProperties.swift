//
//  HabitCD+CoreDataProperties.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 17.02.26.
//
//

public import Foundation
public import CoreData


public typealias HabitCDCoreDataPropertiesSet = NSSet

extension HabitCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitCD> {
        return NSFetchRequest<HabitCD>(entityName: "HabitCD")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var completed: Bool

}

extension HabitCD : Identifiable {

}
