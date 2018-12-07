//
//  GroceryController.swift
//  GroceryList
//
//  Created by Steve Lederer on 12/7/18.
//  Copyright © 2018 Steve Lederer. All rights reserved.
//

import Foundation
import CoreData

class GroceryController {
    
    // MARK: - Properties
    // Singleton
    static let shared = GroceryController() ; private init() {}

    // MARK: - CRUD Functions
    func createGroceryItem(with name: String) {
        Grocery(name: name)
        saveToPersistentStore()
    }
    
    func delete(grocery: Grocery) {
        CoreDataStack.context.delete(grocery)
        saveToPersistentStore()
    }
    
    func toggle(grocery: Grocery) {
        grocery.inCart.toggle()
    }
    
    // MARK: - Save to Persistent Store
    func saveToPersistentStore() {
        do {
            try CoreDataStack.context.save()
        } catch {
            print("❌ There was an error in \(#function) :  \(error) \(error.localizedDescription)")
        }
    }
}
