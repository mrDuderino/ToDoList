//
//  TaskList.swift
//  ToDoList
//
//  Created by Vladimir Strepitov on 29.04.2022.
//

import UIKit
import CoreData

protocol TaskListDelegate: AnyObject {
    func saveTaskTitle(withTitle title: String, withText text: String)
}

class TaskList: UITableViewController, TaskListDelegate {

    var tasks: [Task] = []
    
    @IBAction func saveTaskTitle(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task",
                                                message: "Please add a new task title",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let tf = alertController.textFields?.first
            if let newTaskTitle = tf?.text {
                self.saveTaskTitle(withTitle: newTaskTitle, withText: "")
                self.tableView.reloadData()
            }
        }
        alertController.addTextField()
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    internal func saveTaskTitle(withTitle title: String, withText text: String) {
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        if let objects = try? context.fetch(fetchRequest) {
            for obj in objects {
                if obj.title == title {
                    obj.textOfTask = text
                }
            }
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {return}
        let taskObj = Task(entity: entity, insertInto: context)
        taskObj.title = title
        taskObj.textOfTask = text
        
        do {
            try context.save()
            tasks.append(taskObj)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func deleteContextData() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        if let objects = try? context.fetch(fetchRequest) {
            for obj in objects {
                context.delete(obj)
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.viewControllers.first?.title = "To-Do List"
        //deleteContextData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //cell.selectionStyle = .blue
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowTaskDetails" else {return}
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let detailVC = segue.destination as! DetailTask
            detailVC.pageTitle = tasks[indexPath.row].title!
            detailVC.taskText = tasks[indexPath.row].textOfTask!
            //detailVC.tasks = tasks
        }
    }
}
