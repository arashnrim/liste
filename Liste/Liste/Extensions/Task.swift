//
//  Task.swift
//  Liste
//
//  Created by Arash Nur Iman on 10/07/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import Foundation

struct Task {
    var taskName: String
    var dueDate: String
}

extension TasksViewController {
    
    func convertJSONToTask(tasks: [String: [String:Any]]) -> [Task] {
        var output = [Task]()
        
        for task in tasks {
            let data = task.value
            guard let taskName = data["taskName"] as? String else {
                print("Error: taskName in \(task.key) is not a String.")
                return []
            }
            guard let dueDate = data["dueDate"] as? String else {
                print("Error: dueDate in \(task.key) is not a String.")
                return []
            }
            
            let convertedTask = Task(taskName: taskName, dueDate: dueDate)
            output.append(convertedTask)
        }
        
        return output
    }
    
}
