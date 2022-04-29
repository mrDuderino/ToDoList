//
//  DetailTask.swift
//  ToDoList
//
//  Created by Vladimir Strepitov on 29.04.2022.
//

import UIKit
import CoreData

class DetailTask: UIViewController {

    weak var delegate: TaskListDelegate?
    //var tasks: [Task] = []
    var pageTitle: String = ""
    var taskText: String = ""
    
    @IBOutlet weak var taskTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private func saveDataInTaskList() {
        delegate?.saveTaskTitle(withTitle: pageTitle, withText: taskText)
    }
    
    private func saveTaskText(withText text: String) {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        if let objects = try? context.fetch(fetchRequest) {
            for obj in objects {
                if obj.title == pageTitle {
                    obj.textOfTask = text
                }
            }
        }
        do {
            try context.save()
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
        
        if let objects = try? context.fetch(fetchRequest) {
            for obj in objects {
                if obj.title == pageTitle {
                    taskTextView.text = obj.textOfTask
                }
            }
        }
//        for elem in tasks {
//            if elem.title == pageTitle {
//                taskTextView.text = elem.textOfTask
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //deleteContextData()
        
        navigationController?.viewControllers[1].title = pageTitle
        taskTextView.text = taskText
        taskTextView.delegate = self
        taskTextView.backgroundColor = view.backgroundColor
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTextView),
                                               name: UIResponder.keyboardDidChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTextView),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func updateTextView(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else {return}
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        if notification.name == UIResponder.keyboardWillHideNotification {
            taskTextView.contentInset = .zero
        } else {
            taskTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height - bottomConstraint.constant, right: 0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension DetailTask: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = .white
        textView.textColor = .black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        saveTaskText(withText: textView.text)
        textView.backgroundColor = self.view.backgroundColor
        textView.textColor = .black
    }
}
