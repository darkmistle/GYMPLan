//
//  ExercisesVC.swift
//  GYMPlan
//
//  Created by Demon Vegan on 14.03.2022.
//

import UIKit
import CoreData

class ExercisesVC: UITableViewController {
    
    var exerciseArray = [Exercise]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedGroup: MuscleGroups? {
        didSet {
            loadExercises()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadExercises()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath)
        let exercise = exerciseArray[indexPath.row]
        cell.textLabel!.text = exercise.title
        cell.accessoryType = exercise.done ? .checkmark : .none
        return cell
    }
    
    //MARK: - Data manipulation
    
    func saveExercises() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadExercises(with request: NSFetchRequest<Exercise> = Exercise.fetchRequest(), predicate: NSPredicate? = nil) {
        let groupPredicate = NSPredicate(format: "parentGroup.name MATCHES %@", selectedGroup!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupPredicate, additionalPredicate])
        } else {
            request.predicate = groupPredicate
        }
        do {
            exerciseArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
            tableView.reloadData()
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        context.delete(exerciseArray[indexPath.row])
//        exerciseArray.remove(at: indexPath.row)
        exerciseArray[indexPath.row].done = !exerciseArray[indexPath.row].done
        saveExercises()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    //MARK: - Add new muscle groups

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new exercise", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add exercise", style: .default) { (action) in
            let newExercise = Exercise(context: self.context)
            newExercise.title = textField.text!
            newExercise.done = false
            newExercise.parentGroup = self.selectedGroup
            self.exerciseArray.append(newExercise)
            self.saveExercises()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new exercise"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Search bar methods

extension ExercisesVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Exercise> = Exercise.fetchRequest()

        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadExercises(with: request, predicate: predicate)

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadExercises()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
