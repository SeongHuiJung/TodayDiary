//
//  AccountInfo+CoreDataProperties.swift
//  
//
//  Created by 정성희 on 1/5/25.
//
//

import Foundation
import CoreData


extension AccountInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountInfo> {
        return NSFetchRequest<AccountInfo>(entityName: "AccountInfo")
    }

    @NSManaged public var isRegistered: Bool

}
