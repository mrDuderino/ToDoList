//
//  TaskList.swift
//  ToDoList
//
//  Created by Vladimir Strepitov on 29.04.2022.
//

import UIKit
import CoreData

class TaskList: UITableViewController {

    var tasks: [Task] = []
    lazy var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    
    @IBOutlet var todoTableView: UITableView!
    
    
    @IBAction func saveTaskTitle(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task",
                                                message: "Please add a new task title",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let tf = alertController.textFields?.first
            if let newTaskTitle = tf?.text {
                self.saveTaskTitle(withTitle: newTaskTitle)
                self.tableView.reloadData()
            }
        }
        alertController.addTextField()
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    internal func saveTaskTitle(withTitle title: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context!) else {return}
        let taskObj = Task(entity: entity, insertInto: context)
        taskObj.title = title
        
        do {
            try context?.save()
            tasks.append(taskObj)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func deleteContextData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        if let objects = try? context?.fetch(fetchRequest) {
            for obj in objects {
                context?.delete(obj)
            }
        }
        do {
            try context?.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try context!.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        //deleteContextData()
    }
    
    func setupNavigationBar() {
        //navigationController?.viewControllers.first?.title = "To-Do List"
        let label = UILabel()
        label.text = "To-Do List"
        label.font = UIFont(name: "GeezaPro-Bold", size: 30)
        label.textColor = .systemIndigo
        navigationItem.titleView = label
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .systemIndigo
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemIndigo]
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    func setupTableView() {
        todoTableView.backgroundColor = .systemYellow
        todoTableView.separatorColor = .systemIndigo
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
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        cell.textLabel?.textColor = .systemIndigo
        cell.textLabel?.font = UIFont(name: "Baskerville-Bold", size: 20)
        cell.backgroundColor = .systemYellow
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowTaskDetails" else {return}
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let detailVC = segue.destination as! DetailTask
            detailVC.context = self.context
            detailVC.currentCell = indexPath.row
        }
    }
}
