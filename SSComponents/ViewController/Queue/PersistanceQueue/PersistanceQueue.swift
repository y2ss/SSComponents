//
//  PersistanceQueue.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/12.
//  Copyright © 2018年 y2ss. All rights reserved.
//

typealias PersistanceQueueTaskCallback = (PersistanceQueueTask) -> Void
typealias PersistanceQueueCompletionCallback = (NSError?, PersistanceQueueTask) -> Void

enum PersistanceQueueLogLevel {
    case trace
    case debug
    case info
    case warning
    case error
    var toString: String {
        switch self {
        case .trace:
            return "Trace"
        case .debug:
            return "Debug"
        case .info:
            return "info"
        case .warning:
            return "warning"
        case .error:
            return "error"
        }
    }
}

protocol PersistanceQueueLogProvider {
    func log(_ level: PersistanceQueueLogLevel, msg: String)
}

protocol PersistanceQueueSerializationProvider {
    func serializerTask(_ task: PersistanceQueueTask, queueName: String)
    func deserializeTasksInQueue(_ queue: PersistanceQueue) ->  [PersistanceQueueTask]
    func removeTask(taskID: String, queue: PersistanceQueue)
}

class PersistanceQueue: OperationQueue {
    let maxRetries: Int
    private let serializationProvider: PersistanceQueueSerializationProvider?
    private let logProvider: PersistanceQueueLogProvider?
    private var tasksMap = [String: PersistanceQueueTask]()
    private var taskHandlers = [String: PersistanceQueueTaskCallback]()
    private let completionBlock: PersistanceQueueCompletionCallback?
    
    var tasks: [PersistanceQueueTask] {
        let array = operations
        var output = [PersistanceQueueTask]()
        output.reserveCapacity(array.count)
        for obj in array {
            if let cast = obj as? PersistanceQueueTask {
                output.append(cast)
            }
        }
        return output
    }
    
    init(_ queueName: String, maxConcurrency: Int = 1,
         maxRetries: Int = 5,
         logProvider: PersistanceQueueLogProvider? = nil,
         serializationProvider: PersistanceQueueSerializationProvider? = nil,
         completionBlock: PersistanceQueueCompletionCallback? = nil) {
        self.maxRetries = maxRetries
        self.logProvider = logProvider
        self.serializationProvider = serializationProvider
        self.completionBlock = completionBlock
        super.init()
        self.name = queueName
        self.maxConcurrentOperationCount = maxConcurrency
    }
    
    func addTaskHandler(_ taskType: String, taskHandler: @escaping PersistanceQueueTaskCallback) {
        taskHandlers[taskType] = taskHandler
    }
    
    func loadSerializedTasks() {
        if let sp = serializationProvider {
            let tasks = sp.deserializeTasksInQueue(self)
            for task in tasks {
                task.setupDependencies(tasks)
                addDeserializedTask(task)
            }
        }
    }
    
    func getTask(_ taskID: String) -> PersistanceQueueTask? {
        return tasksMap[taskID]
    }
    
    override func addOperation(_ op: Operation) {
        if let task = op as? PersistanceQueueTask {
            if tasksMap[task.taskID] != nil {
                log(.warning, msg: "Attempted to add duplicate task \(task.taskID)")
                return
            }
            tasksMap[task.taskID] = task
            
            if let sp = serializationProvider, let queueName = task.queue.name {
                sp.serializerTask(task, queueName: queueName)
            }
        }
        op.completionBlock = { self.taskComplete(op) }
        super.addOperation(op)
    }
    
    func addDeserializedTask(_ task: PersistanceQueueTask) {
        if tasksMap[task.taskID] != nil {
            log(.warning, msg: "Attempted to add duplicate deserialized task \(task.taskID)")
            return
        }
        task.completionBlock = { self.taskComplete(task) }
        super.addOperation(task)
    }
    
    func runTask(_ task: PersistanceQueueTask) {
        if let handler = taskHandlers[task.taskType] {
            handler(task)
        } else {
            log(.warning, msg: "No handler registered for task \(task.taskID)")
            task.cancel()
        }
    }
    
    func taskComplete(_ op: Operation) {
        if let task = op as? PersistanceQueueTask {
            tasksMap.removeValue(forKey: task.taskID)
            if let handler = completionBlock {
                handler(task.lastError, task)
            }
            if let sp = serializationProvider {
                sp.removeTask(taskID: task.taskID, queue: task.queue)
            }
        }
    }
    
    func log(_ level: PersistanceQueueLogLevel, msg: String) {
        logProvider?.log(level, msg: msg)
    }
}


class PersistanceQueueTask: Operation {
    static let MIN_RETRY_DELAY = 0.2
    static let MAX_RETRY_DELAY = 60.0
    
    let queue: PersistanceQueue
    let taskID: String
    let taskType: String
    let data: Any?
    let created: Date
    var started: Date?
    var retries: Int
    
    let dependencyStrs: [String]
    var lastError: NSError?
    
    override var name: String? {
        get {
            return taskID
        }
        set {}
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _isExecuting = false
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
        get {
            return _isExecuting
        }
    }
    
    private var _isFinished = false
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        get {
            return _isFinished
        }
    }
    
    init(_ queue: PersistanceQueue, taskID: String? = nil,
         taskType: String, dependencyStrs: [String] = [],
         data: Any? = nil, created: Date = Date(),
         started: Date? = nil, retries: Int = 0, queuePriority: Operation.QueuePriority = .normal, qualityOfService: QualityOfService = .utility) {
        self.queue = queue
        self.taskID = taskID ?? UUID.init().uuidString
        self.taskType = taskType
        self.dependencyStrs = dependencyStrs
        self.data = data
        self.created = created
        self.started = started
        self.retries = retries
        super.init()
        self.queuePriority = queuePriority
        self.qualityOfService = qualityOfService
    }
    
    convenience init(_ queue: PersistanceQueue, type: String, data: Any? = nil, retries: Int = 0, priority: Operation.QueuePriority = .normal, quality: QualityOfService = .utility) {
        self.init(queue, taskType: type, data: data, retries: retries, queuePriority: priority, qualityOfService: quality)
    }
    
    convenience init(_ queue: PersistanceQueue, taskType: String) {
        self.init(queue, type: taskType)
    }
    
    convenience init?(_ dictionary: [String: Any?], queue: PersistanceQueue) {
        if
            let taskID = dictionary["taskID"] as? String,
            let taskType = dictionary["taskType"] as? String,
            let dependencyStrs = dictionary["dependencies"] as? [String]? ?? [],
            let queuePriority = dictionary["queuePriority"] as? Int,
            let qualityOfService = dictionary["qualityOfService"] as? Int,
            let createdStr = dictionary["created"] as? String,
            let retries = dictionary["retries"] as? Int? ?? 0 {
            
            let data: Any? = dictionary["data"] ?? [:]
            let startedStr: String? = dictionary["started"] as? String
            
            let create = DateFormatter.default.date(from: createdStr) ?? Date()
            let started = startedStr != nil ? DateFormatter.default.date(from: startedStr!) : nil
            let priority = Operation.QueuePriority.init(rawValue: queuePriority) ?? .normal
            let qos = QualityOfService.init(rawValue: qualityOfService) ?? .utility
           
            self.init(queue, taskID: taskID, taskType: taskType, dependencyStrs: dependencyStrs, data: data, created: create, started: started, retries: retries, queuePriority: priority, qualityOfService: qos)
        } else {
            self.init(queue, taskID: "", taskType: "")
            return nil
        }
    }
    
    convenience init?(_ json: String, queue: PersistanceQueue) {
        do {
            if let dict = try fromJSON(json) as? [String: Any] {
                self.init(dict, queue: queue)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func setupDependencies(_ allTasks: [PersistanceQueueTask]) {
        dependencyStrs.forEach { taskID in
            let found = allTasks.filter({
                taskID == $0.name
            })
            if let task = found.first {
                self.addDependency(task)
            } else {
                let name = self.name ?? "(unknown)"
                self.queue.log(.warning, msg: "Discarding missing dependency \(taskID) from \(name)")
            }
        }
    }
    
    func toDictionary() -> [String: Any?] {
        var dict = [String: Any?]()
        dict["taskID"] = self.taskID
        dict["taskType"] = self.taskType
        dict["dependencies"] = self.dependencyStrs
        dict["queuePriority"] = self.queuePriority.rawValue
        dict["qualityOfService"] = self.qualityOfService.rawValue
        dict["data"] = self.data
        if #available(iOS 10.0, *) {
            dict["created"] = self.created.toString(from: "yyyy-MM-dd HH:mm:ss")
            dict["started"] = self.started != nil ? self.started!.toISOString() : nil
        }
        dict["retries"] = self.retries
        return dict
    }
    
    func toJSONString() -> String? {
        let dict = toDictionary()
        let nsdict = NSMutableDictionary.init(capacity: dict.count)
        for (key, value) in dict {
            nsdict[key] = value ?? NSNull()
        }
        do {
            let json = try toJSON(nsdict)
            return json
        } catch {
            return nil
        }
    }
    
    override func cancel() {
        lastError = NSError.init(domain: "ssQueue", code: -333, userInfo: [NSLocalizedDescriptionKey: "Task \(taskID) was cancelled"])
        super.cancel()
        queue.log(.debug, msg: "canceled task \(taskID)")
        isFinished = true
    }

    override func start() {
        super.start()
        isExecuting = true
        run()
    }
    
    func run() {
        if isCancelled && !isFinished {
            isFinished = true
        }
        if isFinished { return }
        queue.runTask(self)
    }
    
    func completed(_ error: NSError?) {
        if !isExecuting {
            queue.log(.debug, msg: "completion called on aleardy completed task \(taskID)")
            return
        }
        if let error = error {
            lastError = error
            queue.log(.warning, msg: "task \(taskID) failed with error: \(error)")
            if retries >= queue.maxRetries - 1 {
                queue.log(.error, msg: "max retries exceeded for task \(taskID)")
                cancel()
                return
            }
            let exp = Double(min(queue.maxRetries, retries))
            let seconds: TimeInterval = min(PersistanceQueueTask.MAX_RETRY_DELAY, PersistanceQueueTask.MIN_RETRY_DELAY * pow(2, exp - 1))
            queue.log(.debug, msg: "waiting \(seconds) seconds to retry task \(taskID)")
            runInBackgroundAfter(seconds) { () -> (Void) in
                self.run()
            }
        } else {
            lastError = nil
            queue.log(.debug, msg: "task \(taskID) completed")
            isFinished = true
        }
    }
    
    private func runInBackgroundAfter(_ seconds: TimeInterval, closure: @escaping () -> (Void)) {
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds, execute: closure)
    }
}


