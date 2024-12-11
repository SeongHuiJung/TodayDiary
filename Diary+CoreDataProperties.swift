//
//  Diary+CoreDataProperties.swift
//  TodayDiary
//
//  Created by 정성희 on 12/12/24.
//
//

import Foundation
import CoreData


extension Diary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Diary> {
        return NSFetchRequest<Diary>(entityName: "Diary")
    }

    @NSManaged public var date: Date?
    @NSManaged public var text: String?
    @NSManaged public var emoji: Int64
    @NSManaged public var uuid: UUID?

}

extension Diary : Identifiable {

}
