//
//  DetailTask.swift
//  ToDoList
//
//  Created by Vladimir Strepitov on 29.04.2022.
//

import UIKit
import CoreData

class DetailTask: UIViewController {

    var currentCell: Int = 0
    var context: NSManagedObjectContext?
    
    @IBOutlet weak var taskTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private func saveTaskText(withText text: String) {
        let task = getTaskFromContext(context: self.context!)
        task.textOfTask = text
        do {
            try context?.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func getTaskFromContext(context: NSManagedObjectContext) -> Task {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let objects = try? context.fetch(fetchRequest)
        return objects![currentCell]
    }
    
    func setupNavigationBar() {
        let label = UILabel()
        label.text = "Detail view"
        label.font = UIFont(name: "GeezaPro-Bold", size: 18)
        label.textColor = .systemIndigo
        
        navigationItem.titleView = label
        navigationItem.title = getTaskFromContext(context: self.context!).title
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        taskTextView.text = getTaskFromContext(context: self.context!).textOfTask
        taskTextView.textColor = .systemIndigo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        view.backgroundColor = .systemYellow
        taskTextView.delegate = self
        taskTextView.backgroundColor = view.backgroundColor
        taskTextView.layer.cornerRadius = 13
        taskTextView.font = UIFont(name: "Helvetica", size: 20)
        
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
        textView.textColor = .systemIndigo
    }
}
