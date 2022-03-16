//
//  ViewController.swift
//  GYMPlan
//
//  Created by Demon Vegan on 14.03.2022.
//

import UIKit
import CoreData

class MuscleGroupsVC: UITableViewController {
    
    var groupArray = [MuscleGroups]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGroups()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        let group = groupArray[indexPath.row]
        cell.textLabel?.text = group.name
        return cell
    }
    //MARK: - Data manipulation
    
    func saveGroups() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadGroups(with request: NSFetchRequest<MuscleGroups> = MuscleGroups.fetchRequest()) {
        do {
            groupArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToExercises", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ExercisesVC
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedGroup = groupArray[indexPath.row]
        }
    }
    
    //MARK: - Add new muscle groups
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new group", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add group", style: .default) { (action) in
            let newGroup = MuscleGroups(context: self.context)
            newGroup.name = textField.text
            self.groupArray.append(newGroup)
            self.saveGroups()
        }
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create new group"
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

