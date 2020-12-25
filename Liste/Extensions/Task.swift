//
//  Task.swift
//  Liste
//
//  Created by Arash Nur Iman on 10/07/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase
import RNCryptor

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

        let password = UserDefaults.standard.string(forKey: "masterPassword")

        for task in tasks {
            let data = task.value
            var extractedTaskName: String = ""
            var extractedDescription: String? = ""
            if let password = password {
                if let taskName = data["taskName"] as? Data {
                    do {
                        let decryptedData = try RNCryptor.decrypt(data: taskName, withPassword: password)
                        extractedTaskName = String(decoding: decryptedData, as: UTF8.self)
                    } catch {
                        self.performSegue(withIdentifier: "decrypt", sender: nil)
                    }
                }
                if let description = data["description"] as? Data {
                    do {
                        let decryptedData = try RNCryptor.decrypt(data: description, withPassword: password)
                        extractedDescription = String(decoding: decryptedData, as: UTF8.self)
                    } catch {
                        self.performSegue(withIdentifier: "decrypt", sender: nil)
                    }
                }
            } else {
                guard let taskName = data["taskName"] as? String else {
                    print("Error: taskName in \(task.key) is not a String.")
                    return []
                }
                extractedTaskName = taskName
                extractedDescription = data["description"] as? String
            }
            guard let dueDate = data["dueDate"] as? Timestamp else {
                print("Error: dueDate in \(task.key) is not a Timestamp.")
                return []
            }
            guard let completionStatus = data["completionStatus"] as? Bool else {
                print("Error: completionStatus in \(task.key) is not a Bool.")
                return []
            }
            var convertedTask: Task

            if let description = extractedDescription {
                convertedTask = Task(taskName: extractedTaskName, dueDate: dueDate.dateValue(), description: description, completionStatus: completionStatus)
            } else {
                convertedTask = Task(taskName: extractedTaskName, dueDate: dueDate.dateValue(), description: nil, completionStatus: completionStatus)
            }
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
            var convertedTask: [String: Any]

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

            let password = UserDefaults.standard.string(forKey: "masterPassword")
            if let password = password {
                guard let taskNameData = taskName.data(using: .utf8) else { return [:] }
                let encryptedTaskName = RNCryptor.encrypt(data: taskNameData, withPassword: password)
                convertedTask["taskName"] = encryptedTaskName

                if convertedTask["description"] != nil {
                    guard let descriptionData = (convertedTask["description"] as! String).data(using: .utf8) else { return [:] }
                    let encryptedDescription = RNCryptor.encrypt(data: descriptionData, withPassword: password)
                    convertedTask["description"] = encryptedDescription
                }
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
