//
//  ShoppingTableViewController.swift
//  ShoppingList
//
//  Created by Inga Kirsona on 09/09/2020.
//  Copyright © 2020 Inga Kirsona. All rights reserved.
//

import UIKit
import CoreData

class ShoppingTableViewController: UITableViewController {
    
    var groceries = [Grocery]()
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDeleggate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDeleggate.persistentContainer.viewContext
        loadData()
    }
    
    @IBAction func addNewItemTaped(_ sender: Any) {
        pickNewGrocery()
    }
    
    func pickNewGrocery(){
        let alertController = UIAlertController(title: "Grocery Item!", message: "What do you want to buy?", preferredStyle: .alert)
        alertController.addTextField { (textField: UITextField) in
        }
        let addAction = UIAlertAction(title: "Add", style: .cancel) { (action: UIAlertAction) in
            let textField = alertController.textFields?.first
            let entity = NSEntityDescription.entity(forEntityName: "Grocery", in: self.managedObjectContext!)
            let grocery = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            //-------> to add text to item
            grocery.setValue(textField?.text, forKey: "item")
//-------> to save text to Grocery
            do {
                try self.managedObjectContext?.save()
            }catch{
                fatalError("Error to store Grocery item")
            }
//-------> nedd to load because it reloads tableview
            self.loadData()
        }//end addAction
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
//-------> to fetch and reload a tableview
    func loadData(){
        let request: NSFetchRequest<Grocery> = Grocery.fetchRequest()
        do{
            let result = try managedObjectContext?.fetch(request)
            groceries = result!
            tableView.reloadData()
        }catch{
            fatalError("Error in retrieving Grocery items")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceries.count
    }
//-------> cell formatting
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell", for: indexPath)
        let grocery = groceries[indexPath.row]
        cell.textLabel?.text = grocery.value(forKey: "item") as? String
        cell.selectionStyle = .none
        cell.accessoryType = grocery.completed ? .checkmark : .none
        return cell
    }
    
//-------> to deselect checkmark
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        groceries[indexPath.row].completed = !groceries[indexPath.row].completed
        errorHandling()
    }
//-------> to add delete option and alert
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Are you sure you want to delete?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
                self.managedObjectContext?.delete(self.groceries[indexPath.row])
                UIView.transition(with: tableView, duration: 1.0, options: .transitionCurlUp, animations: {
                    self.loadData()
                }, completion: nil)
            }))
            self.present(alert, animated: true)}
        errorHandling()
    }
    
//-------> to add an animation to cells
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.9){
            cell.transform = CGAffineTransform.identity
        }
    }
    func errorHandling(){
        do {
            try self.managedObjectContext?.save()
        }catch{
            fatalError("Error in deleting item")
        }
        loadData()
    }
}
