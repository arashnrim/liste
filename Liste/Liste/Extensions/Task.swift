//
//  Task.swift
//  Liste
//
//  Created by Arash Nur Iman on 10/07/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase

/**
 * A struct that contains all data required and related to a task in-app.
 *
 * This struct contains `taskName`, `dueDate`, and `completionStatus` that defines more details of the user's task.
 */
struct Task {
    var taskName: String
    var dueDate: Date
    var completionStatus: Bool
}

extension UIViewController {
    
    /**
     * Converts an input of tasks to the `Task` struct type.
     *
     * - Parameters:
     *      - tasks: A `[String: [String:Any]]` parameter to convert from. This specific type is required as the Firestore database is structured to this.
     *
     * - Returns: A `[Tasks]` array with the converted tasks.
     */
    func convertJSONToTask(tasks: [String: [String:Any]]) -> [Task] {
        var output = [Task]()
        
        for task in tasks {
            let data = task.value
            guard let taskName = data["taskName"] as? String else {
                print("Error: taskName in \(task.key) is not a String.")
                return []
            }
            guard let dueDate = data["dueDate"] as? Timestamp else {
                print("Error: dueDate in \(task.key) is not a String.")
                return []
            }
            guard let completionStatus = data["completionStatus"] as? Bool else {
                print("Error: completionStatus in \(task.key) is not a Bool.")
                return []
            }
            
            let convertedTask = Task(taskName: taskName, dueDate: dueDate.dateValue(), completionStatus: completionStatus)
            output.append(convertedTask)
        }
        
        return output
    }
    
    
    func convertDateToString(date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .long
        
        return timeFormatter.string(from: date)
    }
    
    func convertStringToDate(string: String) -> Date {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzzz"
        
        return timeFormatter.date(from: string)!
    }
    
}
