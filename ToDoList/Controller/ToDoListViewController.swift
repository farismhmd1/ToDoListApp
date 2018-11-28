//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Apple on 11/27/18.
//  Copyright © 2018 Faris. All rights reserved.
//

import UIKit
import CoreData
import GoogleSignIn

class ToDoListViewController: UIViewController {
    
    @IBOutlet var listTableView: UITableView!
    @IBOutlet var addTaskButton: UIButton!
    
    let toDoCellReUseIdentifier = "toDoListCellIdentifier"
    var context: NSManagedObjectContext?
    var toDoList: [ToDo]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        listTableView.delegate = self
        listTableView.dataSource = self
        // context from app delegate singleton
        context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        setUpUIComponets()
    }
    override func viewWillAppear(_ animated: Bool) {
        // Get all data from DB
        DBHelper.loadData(myContext: context) { [weak self] (data) in
            if let tempData = data {
                self?.toDoList = tempData
                print("Data loaded successfully...")
                DispatchQueue.main.async {
                    self?.listTableView.reloadData()
                }
            }
        }
        
    }
    
    
    //MARK:- Button Actions
    // Add new task button tapped
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        loadToDoDetailViewController(toDoDetail: nil, toDoIndex: nil)
    }
    
    
    
    //MARK:- TableView Cell Tap Actions
    @objc func toDoTitleLabelTapped(_ sender: Any) {
        if let tapGesture = sender as? UITapGestureRecognizer {
            if let label = tapGesture.view as? UILabel {
                let index = label.tag - Constants.toDoTitleTag
                loadToDoDetailViewController(toDoDetail: toDoList?[index].name, toDoIndex: index)
            }
        }
    }
    @IBAction func toDoFinishButtonTapped(_ sender: Any) {
        if let button = sender as? UIButton {
            let index = button.tag - Constants.toDoFinishButtonTag
            let indexPath = IndexPath(row: index, section: 0)
            
            if  let cell = listTableView.cellForRow(at: indexPath) as? ToDoListTableViewCell {
                if toDoList?[indexPath.row].status == finishedState.notFinished.rawValue {
                    DBHelper.editToDo(myContext: context, toDoList: toDoList!, taskName: toDoList?[indexPath.row].name! ?? "", itemIndex: indexPath.row, status: finishedState.finished.rawValue) { (status) in
                        cell.finishTaskButton.setImage(UIImage(named: "mark"), for: .normal)
                    }
                } else {
                    DBHelper.editToDo(myContext: context, toDoList: toDoList!, taskName: toDoList?[indexPath.row].name! ?? "", itemIndex: indexPath.row, status: finishedState.notFinished.rawValue) { (status) in
                        cell.finishTaskButton.setImage(UIImage(named: "unmark"), for: .normal)
                    }
                }
            }
        }
    }
    
    
    //MARK:- Other Methods
    // Setup ui components
    func setUpUIComponets() {
        //addTaskButton style
        addTaskButton.layer.cornerRadius = addTaskButton.frame.size.width/2
        
        // Set Log out button if Google used Google Sign in
        // Google Auth check
        if GIDSignIn.sharedInstance()?.hasAuthInKeychain() ?? false {
            logoutButtonVisiblity(showLogout: true)
        } else {
            print("Not signed in")
            logoutButtonVisiblity(showLogout: false)
        }
    }
    // Set Logout button based on Google login status
    func logoutButtonVisiblity(showLogout: Bool) {
        if showLogout {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(googleLogOut))
        } else {
            navigationItem.rightBarButtonItems = []
        }
    }
    // Google Logout button
    @objc func googleLogOut() {
        // Delete DB data
        DBHelper.deleteToDoListDBData(myContext: context)
        // Set User Defaults to initial state
        UserDefaults.standard.set(false, forKey: Constants.userDefaultsKey.isLoginSkipped)
        UserDefaults.standard.synchronize()
        GIDSignIn.sharedInstance().signOut()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.loadLoginVC()
    }
    // Method for loading To Do Detail View Controller
    func loadToDoDetailViewController(toDoDetail: String?, toDoIndex: Int?) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateEditToDoViewController") as? CreateEditToDoViewController {
            vc.toDoList = toDoList
            vc.taskIndex = toDoIndex
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
//MARK:- Extensions
//MARK: Tableview delegate
extension ToDoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DBHelper.deleteToDo(myContext: context, toDoList: toDoList!, itemIndex: indexPath.row) { (status) in
                DBHelper.loadData(myContext: context, completion: { [weak self] (data) in
                    if let tempData = data {
                        self?.toDoList = tempData
                        DispatchQueue.main.async {
                            tableView.reloadData()
                        }
                    }
                })
            }
            
        }
    }
}
//MARK: Tableview datasourse
extension ToDoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = toDoList?.count ?? 0
        if toDoList?.count == 0 {
            // Show Empty message if no data
            tableView.setEmptyMessage(Constants.ErrorMessageConstants.emptyToDoList)
        } else {
            tableView.restore()
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: toDoCellReUseIdentifier) as! ToDoListTableViewCell
        cell.setUpCellItems(toDo: toDoList![indexPath.row], index: indexPath.row)
        
        // Add tap gesture for detecting title label tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.toDoTitleLabelTapped(_:)))
        cell.taskDetailLabel.addGestureRecognizer(tapGesture)
        return cell
    }
}
