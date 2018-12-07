//
//  Grocery+Convenience.swift
//  GroceryList
//
//  Created by Steve Lederer on 12/7/18.
//  Copyright © 2018 Steve Lederer. All rights reserved.
//

import Foundation
import CoreData

extension Grocery {
    @discardableResult
    convenience init(name: String, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.name = name
    }
}
