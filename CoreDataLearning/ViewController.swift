//
//  ViewController.swift
//  CoreDataLearning
//
//  Created by Cumulations Technologies Private Limited on 20/04/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
 
    
    @IBOutlet weak var tableView: UITableView!
    
    // reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items:[Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get access from core data persistent container
       // (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        fetchData()
        relationship()
    }

    func relationship(){
        
        //create family
        
        var family = Family(context: context)
        family.name = "some family"
        //create person
        
        var person = Person(context: context)
        person.name = "LISA"
        person.family
        //create relationship between person and family
        //person.family = family
        family.addToPeople(person)//add person to family
        
        //save context
        try! context.save()
    }
    
    func fetchData(){
        //fetch data from core data and then display the data on tableview
        do
        {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            //filer or sort or filter and sort based on request
            //NSPredicate is used for memory filtering or searching
//            let pred = NSPredicate(format: "name CONTAINS %@" , "c")
//            request.predicate = pred
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
//            let sort = NSSortDescriptor(key: "name", ascending: false)
            request.sortDescriptors = [sort]

            
            self.items = try context.fetch(request)
            
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
            }
        }
        
        catch
        {
            
        }
    }

    @IBAction func addTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Person", message: "name?", preferredStyle: .alert)
        
        alert.addTextField()
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let textfiled = alert.textFields![0]
            
            //create new person object
            let newPerson = Person(context: self.context)
            
            newPerson.name = textfiled.text
            newPerson.age = 22
            newPerson.gender = "female"
            
            //save data
            
            do{
                try self.context.save()
            }
            catch{
                
            }

            //fetch data
            self.fetchData()
        }
        alert.addAction(submitButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.items?.count ?? 0
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
         
         let person = self.items![indexPath.row]
         cell.textLabel?.text = person.name
         return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //select person
        let person = self.items![indexPath.row]
        
        //create alert when row is selected
        let alert = UIAlertController(title: "Edit person details", message: "edit name", preferredStyle: .alert)
        alert.addTextField()
        
        let textfield = alert.textFields![0]
        textfield.text = person.name
        
        //configure buttton handler
        let saveButton = UIAlertAction(title: "save", style: .default) { (action) in
            let textfield = alert.textFields![0]

            //edit textfield
            person.name = textfield.text
            
            //save the edited data
            do{
                try self.context.save()
            }
            catch{
                
            }
            //fetch the data
            self.fetchData()

        }
        alert.addAction(saveButton)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //create swipe action
        let action = UIContextualAction(style: .destructive, title: "remove") { (action, view, completionHandler) in
            //select person to remove
            let removePerson = self.items![indexPath.row]
            
            //delete the selected person
            self.context.delete(removePerson)
            
            //save the data
            do{
           try self.context.save()
            }
            catch{
                
            }
            
            //refetch data
            self.fetchData()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
}
