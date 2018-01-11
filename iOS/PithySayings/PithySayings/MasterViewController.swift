//
//  MasterViewController.swift
//  PithySayings
//
//  Created by Arthur Nsereko Kahwa on 01/08/2018.
//  Copyright © 2018 Arthur Nsereko Kahwa. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // navigationItem.leftBarButtonItem = editButtonItem

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshCategoryObjects(_:)))
        navigationItem.rightBarButtonItem = refreshButton
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func makeJson(dictionary:NSDictionary) {
        do {
            // let json = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            let decoded = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)

            if let text = NSString(data: decoded, encoding: String.Encoding.utf8.rawValue) {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let firstPath = paths[0]
                let jsonPath = firstPath.appendingPathComponent("fortune.json")
                // print(jsonPath)

                try text.write(to: jsonPath, atomically: true, encoding: String.Encoding.utf8.rawValue)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }

    @objc
    func refreshCategoryObjects(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext

        // Empty the datsbase
        if let storedCategories = self.fetchedResultsController.fetchedObjects {
            for storedCategory in storedCategories {
                context.delete(storedCategory)
            }
        }
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        var resourceFileDictionary: NSDictionary?
        
        if let plistPath = Bundle.main.path(forResource:"fortune", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: plistPath)!
        }

        if let resourceFileDictionary = resourceFileDictionary {
            makeJson(dictionary:resourceFileDictionary)
            
            let keys = resourceFileDictionary.allKeys as? [String]
            let sortedKeys = keys //?.sorted() //.reversed()
            
            for key in sortedKeys! {
                // print("\(key) - \(values)")
                
                let newCategory = Category(context: context)
                newCategory.name = key // as? String
                
                if let sayings = resourceFileDictionary[key] as? [String] {
                    for saying in sayings {
                        let newSaying = Saying(context: context)
                        newSaying.text = saying
                        
                        newCategory.addToSayings(newSaying)
                    }
                }
                
                // Save the context.
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            var category = fetchedResultsController.object(at: indexPath)
                if category.name == "*" {
                    let allCatgories = fetchedResultsController.fetchedObjects
                    if (allCatgories?.isEmpty)! {
                        fatalError("No categories found in Database")
                    }
                    else {
                        let randomOffset = Int(arc4random_uniform(UInt32((allCatgories?.count)!)))
                        let randomIndex = allCatgories?.index((allCatgories?.startIndex)!, offsetBy: randomOffset)
                        category = allCatgories![randomIndex!]
                    }
                }
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.categoryItem = category
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let category = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withCategory: category)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withCategory category: Category) {
        cell.textLabel!.text = category.name
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Category> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withCategory: anObject as! Category)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withCategory: anObject as! Category)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

