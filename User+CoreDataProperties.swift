//
//  User+CoreDataProperties.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 5/21/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var dateOfBirth: String?
    @NSManaged var name: String?
    @NSManaged var height: String?
    @NSManaged var gender: String?

}
