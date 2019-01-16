//
//  PersistanceQueueViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/18.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

private let kAddDependencySettingKey = "settings.addDependency"
private let kAutocompleteTaskSettingKey = "settings.autocompleteTask"

class PersistanceQueueViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var collectionView: UICollectionView!
    var totalTasksSeen = 0
    var nextTaskID = 1
    lazy var queue: PersistanceQueue = {
        return PersistanceQueue("ssQueue", maxConcurrency: 2, maxRetries: 3, logProvider: ConsoleLogger(), serializationProvider: UserDefaultsSerializer(), completionBlock: { [weak self] in self?.taskComplete($0, task: $1) })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: kAutocompleteTaskSettingKey)
        queue.addTaskHandler("cellTask", taskHandler: taskHandler)
        queue.loadSerializedTasks()
        let taskIDs = queue.operations
            .map { return $0 as! PersistanceQueueTask }
            .map { return Int($0.taskID) ?? 0 }
        nextTaskID = 1 + (arrayMax(taskIDs) ?? 0)
    }
    
    override func viewDidLayoutSubviews() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: collectionView.width, height: 50)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        let taskID1 = nextTaskID
        nextTaskID += 1
        let task1 = PersistanceQueueTask.init(queue, taskID: String(taskID1), taskType: "cellTask", dependencyStrs: [], data: [:])
        let shouldAddDependency = UserDefaults.standard.bool(forKey: kAddDependencySettingKey)
        if shouldAddDependency {
            nextTaskID += 1
            let taskID2 = nextTaskID
            let task2 = PersistanceQueueTask.init(queue, taskID: String(taskID2), taskType: "cellTask", dependencyStrs: [], data: [:])
            task1.addDependency(task2)
            queue.addOperation(task2)
        }
        
        queue.addOperation(task1)
        totalTasksSeen = max(totalTasksSeen, queue.operationCount)
        updateProgress()
        collectionView.reloadData()
    }
    
    @IBAction func removeTapped(_ sender: UIButton) {
        if let task = queue.operations.first as? PersistanceQueueTask {
            log(.info, msg: "removing task \(task.taskID)")
            task.cancel()
            collectionView.reloadData()
        }
    }
    
    func taskHandler(_ task: PersistanceQueueTask) {
        log(.info, msg: "Running task \(task.taskID)")
        let taskShouldAutocomplete = UserDefaults.standard.bool(forKey: kAutocompleteTaskSettingKey)
        if taskShouldAutocomplete {
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                task.completed(nil)
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func taskComplete(_ error: NSError?, task: PersistanceQueueTask) {
        if let error = error {
            log(.error, msg: "task \(task.taskID) failed with error: \(error)")
        } else {
            log(.info, msg: "task \(task.taskID) completed successfully")
        }
        if queue.operationCount == 0 {
            nextTaskID = 1
            totalTasksSeen = 0
        }
        updateProgress()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    func updateProgress() {
        let tasks = queue.tasks
        let progress = Double(totalTasksSeen - tasks.count) / Double(totalTasksSeen)
        DispatchQueue.main.async {
            self.progressView.progress = Float(progress)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return queue.operationCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.backgroundColor = UIColor.red
        if let task = queue.operations[indexPath.item] as? PersistanceQueueTask {
            cell.task = task
            cell.nameLabel.text = "task \(task.taskID)"
            let taskShouldAutocomplete = UserDefaults.standard.bool(forKey: kAutocompleteTaskSettingKey)
            if task.isExecuting && !taskShouldAutocomplete {
                cell.backgroundColor = UIColor.blue
                cell.failButton.isEnabled = true
                cell.succeedButton.isEnabled = true
            } else {
                cell.backgroundColor = UIColor.gray
                cell.succeedButton.isEnabled = false
                cell.failButton.isEnabled = false
            }
        }
        return cell
    }
}

class UserDefaultsSerializer: PersistanceQueueSerializationProvider {
    func serializerTask(_ task: PersistanceQueueTask, queueName: String) {
        if let serialized = task.toJSONString() {
            let defaults = UserDefaults.standard
            var stringArr: [String]
            
            if let curStringArr = defaults.stringArray(forKey: queueName) {
                stringArr = curStringArr
                stringArr.append(serialized)
            } else {
                stringArr = [serialized]
            }
            defaults.setValue(stringArr, forKey: queueName)
        } else {
            log(.error, msg: "failed to serialized task \(task.taskID) in queue \(queueName)")
        }
    }
    
    func deserializeTasksInQueue(_ queue: PersistanceQueue) -> [PersistanceQueueTask] {
        let defaults = UserDefaults.standard
        if let queueName = queue.name,
            let stringArray = defaults.stringArray(forKey: queueName) {
            return stringArray
                .map { return PersistanceQueueTask($0, queue: queue) }
                .filter { return $0 != nil }
                .map { return $0! }
        }
        return []
    }
    
    func removeTask(taskID: String, queue: PersistanceQueue) {
        if let queueName = queue.name {
            var curArray: [PersistanceQueueTask] = deserializeTasksInQueue(queue)
            curArray = curArray.filter({ return $0.taskID != taskID })
            
            let stringArr = curArray
                .map { return $0.toJSONString() }
                .filter { return $0 != nil }
                .map { return $0! }
            let defaults = UserDefaults.standard
            defaults.setValue(stringArr, forKey: queueName)
        }
    }
}

class ConsoleLogger: PersistanceQueueLogProvider {
    
    func log(_ level: PersistanceQueueLogLevel, msg: String) {
        return ConsoleLogger.log(level, msg: msg)
    }
    
    class func log(_ level: PersistanceQueueLogLevel, msg: String) {
        DispatchQueue.main.async {
            print("[\(level.toString.uppercased())] \(msg)")
        }
    }
}

func log(_ level: PersistanceQueueLogLevel, msg: String) {
    return ConsoleLogger.log(level, msg: msg)
}


class TaskCell: UICollectionViewCell {
    
    @IBOutlet weak var succeedButton: UIButton!
    @IBOutlet weak var failButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var task: PersistanceQueueTask? = nil
    
    @IBAction func succeedTapped(_ sender: UIButton) {
        if let task = task {
            task.completed(nil)
        }
    }
    
    @IBAction func failTapped(_ sender: UIButton) {
        if let task = task {
            let err = error("User tapped fail on task \(task.taskID)")
            task.completed(err)
        }
    }
}

private func error(_ msg: String) -> NSError? {
    return NSError.init(domain: "persistance", code: -333, userInfo: nil)
}
