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
    var description: String?
    var completionStatus: Bool
}

extension UIViewController {

    /**
     * Converts an input of tasks to the `Task` struct type.
     *
     * - Parameters:
     *      - tasks: A `[String: [String:Any]]` parameter to convert from. This specific type is required as the Firestore database is structured to this.
     *
     * - Returns: A `[Task]` array with the converted tasks.
     */
    func convertJSONToTask(tasks: [String: [String: Any]]) -> [Task] {
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

    /**
     * Converts an input of tasks to the Firestore JSON `[String: [String: Any]` struct type.
     *
     * - Parameters:
     *      - tasks: A `[Task]` parameter to convert from.
     *
     * - Returns: A `[String: [String: Any]]` array with the converted tasks.
     */
    func convertTaskToJSON(tasks: [Task]) -> [String: [String: Any]] {
        var output = [String: [String: Any]]()

        for task in tasks {
            let taskName = task.taskName
            let dueDate = task.dueDate
            let description = task.description
            let completionStatus = task.completionStatus
            let convertedTask: [String: Any]

            if !(description == nil) {
                convertedTask = [
                    "taskName": taskName,
                    "dueDate": Timestamp(date: dueDate),
                    "description": description!,
                    "completionStatus": completionStatus
                    ] as [String: Any]
            } else {
                convertedTask = [
                    "taskName": taskName,
                    "dueDate": Timestamp(date: dueDate),
                    "completionStatus": completionStatus
                    ] as [String: Any]
            }

            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let randomTaskID = String((0..<8).map { _ in letters.randomElement()! })

            output[randomTaskID] = convertedTask
        }

        return output
    }

    /**
     * Converts a `Date` to a readable `String` format.
     *
     * This function specifically changes the `Date` to a String format of "dd MMMM, yyyy".
     *
     * - Parameters:
     *      - date: The `Date` to convert from.
     *
     * - Returns: A `String` of the converted `Date`.
     */
    func convertDateToString(date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .long

        return timeFormatter.string(from: date)
    }

    /**
     * Converts a `String` to a `Date` type.
     *
     * This function assumes that the `String` holds a format of "yyyy-MM-dd HH:mm:ss zzzz". At all costs, please ensure that the `String` is in this format before proceeding.
     *
     * - Parameters:
     *      - string: The `String` to convert from.
     *
     * - Returns: A `Date` of the converted `String`.
     */
    func convertStringToDate(string: String) -> Date {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzzz"

        return timeFormatter.date(from: string)!
    }

}
