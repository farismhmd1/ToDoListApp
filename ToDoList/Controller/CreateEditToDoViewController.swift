//
//  AddEditToDoViewController.swift
//  ToDoList
//
//  Created by Apple on 11/27/18.
//  Copyright © 2018 Faris. All rights reserved.
//

import UIKit
import CoreData
class CreateEditToDoViewController: UIViewController {
    
    @IBOutlet var taskDetailTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var viewButtonsHeightConstraint: NSLayoutConstraint!
    var taskIndex:Int?
    var toDoList:[ToDo]?
    var context: NSManagedObjectContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // context from app delegate singleton
        context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        setupUIComponents()
    }
    
    //MARK:- Button actions
    // Savebutton action
    @IBAction func saveButtonTapped(_ sender: Any) {
        if isValid() {
            // Save data to DB
            if taskIndex == nil {
                // Save new to do
                DBHelper.addNewToDo(myContext: context, taskName: taskDetailTextView.text) { [weak self] (status) in
                    self?.popViewController()
                }
            } else {
                //Edit selected task in DB
                DBHelper.editToDo(myContext: context, toDoList: toDoList!, taskName: taskDetailTextView.text, itemIndex: taskIndex!, status: finishedState.notFinished.rawValue) { [weak self] (status) in
                    self!.popViewController()
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if taskIndex == nil {
            // Pop add new todo view
            popViewController()
        } else {
            //Edit mode
            // Cancel edit mode & show read view mode
            setupReadView()
        }
    }
    
    //MARK:- Other Methods
    func setupUIComponents() {
        if taskIndex == nil {
            // Show create view without edit button
            setUpCreateView()
        } else {
            // Show read view with edit button
            setupReadView()
        }
        
    }
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    // Setup Edit View
    @objc func setupEditView() {
        navigationItem.setRightBarButtonItems([], animated: true)
        taskDetailTextView.isEditable = true
        taskDetailTextView.becomeFirstResponder()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.viewButtonsHeightConstraint.constant = 60
            }
        }
    }
    // Setup Read View
    func setupReadView() {
        taskDetailTextView.text = toDoList?[taskIndex ?? 0].name ?? ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(setupEditView))
        taskDetailTextView.isEditable = false
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.viewButtonsHeightConstraint.constant = 0
            }
        }
    }
    // Setup Cancel View
    func setUpCreateView() {
        navigationItem.setRightBarButtonItems([], animated: true)
        taskDetailTextView.isEditable = true
        taskDetailTextView.becomeFirstResponder()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.viewButtonsHeightConstraint.constant = 60
            }
        }
    }
    // Validate all contents before saving to DB
    func isValid()->Bool {
        guard let text = taskDetailTextView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                // this will be reached if the text is nil (unlikely)
                // or if the text only contains white spaces
                // or no text at all
                showAlertView(message: Constants.ErrorMessageConstants.taskDetailsEmpty)
                return false
        }
        return true
    }
    // UIAlertview
    func showAlertView(message: String) {
        let alert = UIAlertController(title: Constants.appName, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
