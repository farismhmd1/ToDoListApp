//
//  DBHelper.swift
//  ToDoList
//
//  Created by Apple on 11/27/18.
//  Copyright © 2018 Faris. All rights reserved.
//

import Foundation
import CoreData
enum finishedState: String {
    case finished = "finished"
    case notFinished = "notFinished"
}
class DBHelper {
    // Load data from  DB
    static func loadData(myContext:NSManagedObjectContext?, completion: (_ result : [ToDo]?) -> Void) {
        let request:NSFetchRequest<ToDo> = ToDo.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(ToDo.created_time), ascending: false)
        request.sortDescriptors = [sort]
        do{
            if let context = myContext {
                let  data = try context.fetch(request)
                completion(data)
            }
        } catch {
            print("Error fetching data")
            completion(nil)
        }
        completion(nil)
    }
    
    // Insert new data to  DB
    static func addNewToDo(myContext:NSManagedObjectContext?, taskName: String, completion: (_ status: Bool) -> Void) {
        do{
            if let context = myContext {
                let newToDoItem = NSEntityDescription.insertNewObject(forEntityName: "ToDo", into: context) as! ToDo
                newToDoItem.name = taskName
                newToDoItem.status = finishedState.notFinished.rawValue
                newToDoItem.created_time = Date()
                
                try context.save()
                completion(true)
            }
        } catch {
            print("Error storing data...")
            completion(false)
        }
        completion(false)
    }
    
    
    // Edit data in DB
    static func editToDo(myContext:NSManagedObjectContext?, toDoList:[ToDo], taskName: String, itemIndex: Int, status: String, completion: (_ status: Bool) -> Void)  {
        do {
            if let context = myContext {
                let toDo = toDoList[itemIndex]
                toDo.name = taskName
                toDo.status = status
                try context.save()
                completion(true)
            }
        } catch {
            print("Error storing data...")
            completion(false)
        }
    }
    
    // Delete a to do
    static func deleteToDo(myContext:NSManagedObjectContext?, toDoList:[ToDo], itemIndex: Int, completion: (_ status: Bool) -> Void)  {
        do {
            if let context = myContext {
                let toDo = toDoList[itemIndex]
                context.delete(toDo)
                try context.save()
                completion(true)
            }
        } catch {
            print("Error storing data...")
            completion(false)
        }
    }
    // Delete all DB Data
    static func deleteToDoListDBData(myContext:NSManagedObjectContext?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        let deleteReqest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        if let context = myContext {
            do {
                try context.execute(deleteReqest)
            } catch {
                print(error)
            }
        }
    }
}
