//
//  GroceryListTableViewController.swift
//  GroceryList
//
//  Created by Steve Lederer on 12/7/18.
//  Copyright © 2018 Steve Lederer. All rights reserved.
//

import UIKit
import CoreData

class GroceryListTableViewController: UITableViewController {
    
    // MARK: - Properties
    let fetchedResultsController: NSFetchedResultsController<Grocery> = {
        let request: NSFetchRequest<Grocery> = Grocery.fetchRequest()
        let groceryInCartSortDescriptor = NSSortDescriptor(key: "inCart", ascending: true)
        // selector makes name case insentive
        let groceryNameSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        request.sortDescriptors = [groceryInCartSortDescriptor, groceryNameSortDescriptor]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: "inCart", cacheName: nil)
    }()
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ There was an error in \(#function) :  \(error) \(error.localizedDescription)")
        }
        fetchedResultsController.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func newGroceryItemButtonTapped(_ sender: UIBarButtonItem) {
        presentNewGroceryItemAlert()
    }
    
    // MARK: - Table View Data Source and Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections?.count else { return 1 }
        return sections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { fatalError("No sections in fetchedResultsController") }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryItemCell", for: indexPath) as! ButtonTableViewCell
        cell.delegate = self
        let grocery = fetchedResultsController.object(at: indexPath)
        cell.grocery = grocery
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        switch sectionInfo.name {
        case "0":
            return "Items to Buy"
        case "1":
            return "Items in Cart"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grocery = fetchedResultsController.object(at: indexPath)
            GroceryController.shared.delete(grocery: grocery)
        }
    }
}

// MARK: - FetchedResultsControllerDelegate
extension GroceryListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case.delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case.insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case.move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: oldIndexPath, to: newIndexPath)
        case.update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - ButtonCellTableViewDelegate
extension GroceryListTableViewController: ButtonTableViewCellDelegate {
    func buttonCellButtonTapped(_ cell: ButtonTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let grocery = fetchedResultsController.object(at: indexPath)
            GroceryController.shared.toggle(grocery: grocery)
            cell.updateButton(grocery.inCart)
        }
    }
}

// MARK: - Alerts
extension GroceryListTableViewController {
    func presentNewGroceryItemAlert() {
        let alertController = UIAlertController(title: "🛒Grocery List🛒", message: "What do you need to buy?", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter item name..."
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .yes
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addItemAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let groceryItemTextField = alertController.textFields?.first
            GroceryController.shared.createGroceryItem(with: groceryItemTextField?.text ?? "")
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addItemAction)
        present(alertController, animated: true)
    }
}
