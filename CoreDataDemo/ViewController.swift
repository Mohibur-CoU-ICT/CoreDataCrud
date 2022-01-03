//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Brotecs Mac Mini on 12/30/21.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var personTableView: UITableView!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the table
    var persons: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        personTableView.delegate = self
        personTableView.dataSource = self
        
        // Get items from Core Data
        fetchPerson()
    }
    
    func fetchPerson() {
        // Fetch the data from Core Data to display in the tableview
        do {
            try self.persons = context.fetch(Person.fetchRequest())
            DispatchQueue.main.async {
                self.personTableView.reloadData()
            }
        }
        catch {
            
        }
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        // Create alert
        let alert = UIAlertController(title: "Add Person", message: "", preferredStyle: .alert)
        alert.addTextField()
        
        // Configure button handler
        let addButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // Create a person object
            let newPerson = Person(context: self.context)
            newPerson.name = alert.textFields![0].text
            
            // Save the data
            do {
                try self.context.save()
            }
            catch {
                  
            }
            
            // Re-fetch the data
            self.fetchPerson()
        }
        
        // Add Button
        alert.addAction(addButton)
        
        // Show alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Total rows = \(self.persons?.count ?? 0)")
        return self.persons?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = personTableView.dequeueReusableCell(withIdentifier: "personTableViewCell", for: indexPath) as? PersonTableViewCell {
            let person = self.persons?[indexPath.row]
            print("Name of \(indexPath.row) = \(person?.name ?? "none")")
            cell.textLabel?.text = person?.name
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped \(indexPath.row) th person")
        
        // Selected Person
        let selectedPerson = self.persons![indexPath.row]
        
        // Create alert
        let alert = UIAlertController(title: "Edit Person", message: "", preferredStyle: .alert)
        alert.addTextField()
        
        let nameTextField = alert.textFields![0]
        nameTextField.text = selectedPerson.name
        
        // Configure button handler
        let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            // Edit name property of person object
            selectedPerson.name = alert.textFields![0].text
            
            // Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            // Re-fetch the data
            self.fetchPerson()
        }
        
        // Add save button to the alert
        alert.addAction(saveButton)
        
        // Show alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            // Which person to remove
            let personToRemove = self.persons![indexPath.row]
            
            // Remove the person
            self.context.delete(personToRemove)
            
            // Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            // Re-fetch the data
            self.fetchPerson()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}
