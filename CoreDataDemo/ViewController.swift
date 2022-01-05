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
            print("Error in fetchPerson(): " + error.localizedDescription)
        }
    }
    
    
    func showErrorAlert(_ msg: String) {
        let alert = UIAlertController(title: msg, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addButtonTapped(_ sender: Any) {
        // Create alert
        let alert = UIAlertController(title: "Add Person", message: "", preferredStyle: .alert)
        alert.addTextField() // for name
        alert.addTextField() // for age
        alert.addTextField() // for gender
        
        alert.textFields![0].placeholder = "Name"
        alert.textFields![1].placeholder = "Age"
        alert.textFields![2].placeholder = "Gender"
        
        // Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//            self.dismiss(animated: true, completion: nil)
        }
        
        // Configure button handler
        let addAction = UIAlertAction(title: "Add", style: .default) { (action: UIAlertAction!) in
            
            // Edit name property of person object
            guard let name = alert.textFields?[0].text, !name.isEmpty else {
                alert.dismiss(animated: true) {
                    self.showErrorAlert("Name should not be empty")
                }
                
                return
            }
            
            // Edit age property of person object
            guard let ageString = alert.textFields?[1].text, let age = Int64(ageString), age > 0 && age <= 100 else {
                alert.dismiss(animated: true) {
                    self.showErrorAlert("Age should be between 1-100")
                }
                
                return
            }
            
            // Edit gender property of person object
            guard let gender = alert.textFields?[2].text?.lowercased(), (gender=="male" || gender=="female") else {
                alert.dismiss(animated: true) {
                    self.showErrorAlert("Gender should be male or female")
                }
                
                return
            }
            
            // Create a person object
            let newPerson = Person(context: self.context)
            
            newPerson.name = name
            newPerson.age = age
            newPerson.gender = gender.lowercased()
            
            // Save the data
            do {
                try self.context.save()
            }
            catch {
                print("Error in addButtonTapped() : " + error.localizedDescription)
            }
            
            // Re-fetch the data
            self.fetchPerson()
        }
        // Add Button
        alert.addAction(addAction)
        
        alert.addAction(cancelAction)
        // Show alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("Total rows = \(self.persons?.count ?? 0)")
        return self.persons?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = personTableView.dequeueReusableCell(withIdentifier: "personTableViewCell", for: indexPath) as? PersonTableViewCell {
            let person = self.persons?[indexPath.row]
//            print("\(indexPath.row) -> Name = \(person?.name ?? "none"), Age = \(person?.age ?? 0), Gender = \(person?.gender ?? "none")")
            cell.nameValue?.text = person?.name
            cell.ageValue?.text = String(person!.age)
            cell.genderValue?.text = person?.gender
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("You tapped \(indexPath.row) th person")
        
        // Selected Person
        let selectedPerson = self.persons![indexPath.row]
        
        // Create alert
        let alert = UIAlertController(title: "Edit Person", message: "", preferredStyle: .alert)
        alert.addTextField() // for name
        alert.addTextField() // for age
        alert.addTextField() // for gender
        
        alert.textFields![0].text = selectedPerson.name
        alert.textFields![1].text = String(selectedPerson.age)
        alert.textFields![2].text = selectedPerson.gender
        
        // Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
            
        }
        alert.addAction(cancelAction)
        
        // Configure button handler
        let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            // Edit name property of person object
            guard let name = alert.textFields?[0].text, !name.isEmpty else {
                alert.dismiss(animated: true) {
                    self.showErrorAlert("Name should not be empty")
                }
                
                return
            }
            
            // Edit age property of person object
            guard let ageString = alert.textFields?[1].text, let age = Int64(ageString), age > 0 && age <= 100 else {
                alert.dismiss(animated: true) {
                    self.showErrorAlert("Age should be between 1-100")
                }
                
                return
            }
            
            // Edit gender property of person object
            guard let gender = alert.textFields?[2].text?.lowercased(), (gender=="male" || gender=="female") else {
                alert.dismiss(animated: true) {
                    self.showErrorAlert("Gender should be male or female")
                }
                
                return
            }
            
            selectedPerson.name = name
            selectedPerson.age = age
            selectedPerson.gender = gender
            
            // Save the data
            do {
                try self.context.save()
            }
            catch {
                print("Error in didSelectRowAt : " + error.localizedDescription)
            }
            
            // Re-fetch the data
            self.fetchPerson()
        }
        // Add save button to the alert
        alert.addAction(saveButton)
        
        // Show alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // To delete a person when swipe to the left
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
                print("Error in deleting person : " + error.localizedDescription)
            }
            
            // Re-fetch the data
            self.fetchPerson()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}
