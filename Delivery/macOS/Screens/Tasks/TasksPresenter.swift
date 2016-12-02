//
//  TasksPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol TasksPresenterInput: class {
    
    func refreshUI()
    func reloadData()
    func reloadTasksOnDay (_ day: Day, listType: ListType)
    func updateNoTasksState()
    func messageButtonDidPress()
    func startDay()
    func insertTaskWithData (_ taskData: TaskCreationData)
    func insertTaskAfterRow (_ row: Int)
    func removeTaskAtRow (_ row: Int)
}

protocol TasksPresenterOutput: class {
    
    func showLoadingIndicator (_ show: Bool)
    func showMessage (_ message: MessageViewModel)
    func showDates (_ weeks: [Week])
    func showTasks (_ tasks: [Task], listType: ListType)
    func showReports (_ reports: [Report], listType: ListType)
    func selectDay (_ day: Day)
    func presentNewTaskController (withInitialDate date: Date)
}

enum ListType: Int {
    
    case allTasks = 0
    case report = 1
}

class TasksPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var userInterface: TasksPresenterOutput?
    fileprivate var day: NewDay?
    fileprivate var currentTasks = [Task]()
    fileprivate var currentReports = [Report]()
    fileprivate var selectedListType = ListType.allTasks
    
}

extension TasksPresenter: TasksPresenterInput {
    
    func refreshUI() {
        
        // Prevent reloading data when you open the popover for the second time in the same day
        if day == nil || day!.isNewDay() {
            day = NewDay()
            reloadData()
        }
        updateNoTasksState()
    }
    
    func reloadData() {
        
        let todayDay = Day(date: Date())
        let reader = ReadDaysInteractor(repository: localRepository)
        let weeks = reader.weeks()
        userInterface?.showDates(weeks)
        userInterface?.selectDay(todayDay)
        reloadTasksOnDay(todayDay, listType: selectedListType)
    }
    
    func reloadTasksOnDay (_ day: Day, listType: ListType) {
        
        let reader = ReadTasksInteractor(repository: localRepository)
        currentTasks = reader.tasksInDay(day.date)
        selectedListType = listType
        
        if listType == .report {
            let reportInteractor = CreateReport()
            let reports = reportInteractor.reports(fromTasks: currentTasks)
            currentReports = reports.reversed()
            userInterface!.showReports(currentReports, listType: selectedListType)
        }
        else {
            userInterface!.showTasks(currentTasks, listType: selectedListType)
        }
        
        updateNoTasksState()
    }
    
    func updateNoTasksState() {
        
        if currentTasks.count == 0 {
            userInterface!.showMessage((
                title: "Good morning!",
                message: "Ready to begin your working day?",
                buttonTitle: "Start day"))
        } else if currentTasks.count == 1 && selectedListType != .report {
            userInterface!.showMessage((
                title: "No task yet.",
                message: "When you're ready with your first task click \n'+' or 'Log time'",
                buttonTitle: "Log time"))
        } else {
            appWireframe!.removeMessage()
        }
    }
    
    func messageButtonDidPress() {
        
        if currentTasks.count == 0 {
            startDay()
        } else {
            userInterface!.presentNewTaskController(withInitialDate: Date())
        }
    }
    
    func startDay() {
        
        let now = Date()
        let task = Task(dateEnd: now, type: TaskType.startDay)
        let saveInteractor = TaskInteractor(repository: localRepository)
        saveInteractor.saveTask(task)
        day!.setLastTrackedDay(now)
        reloadData()
    }
    
    func insertTaskWithData (_ taskData: TaskCreationData) {
        
        var task = Task(subtype: TaskSubtype.issueEnd)
        task.notes = taskData.notes
        task.taskNumber = taskData.taskNumber
        task.endDate = taskData.dateEnd
        
        let saveInteractor = TaskInteractor(repository: localRepository)
            saveInteractor.saveTask(task)
    }
    
    func insertTaskAfterRow (_ row: Int) {
        
        guard currentTasks.count > row + 1 else {
            userInterface!.presentNewTaskController(withInitialDate: Date())
            return
        }
        let taskBefore = currentTasks[row]
        let taskAfter = currentTasks[row+1]
        let middleTimestamp = taskAfter.endDate.timeIntervalSince(taskBefore.endDate) / 2
        let middleDate = taskBefore.endDate.addingTimeInterval(middleTimestamp)
        userInterface!.presentNewTaskController(withInitialDate: middleDate)
    }
    
    func removeTaskAtRow (_ row: Int) {
        
        let task = currentTasks[row]
        currentTasks.remove(at: row)
        let deleteInteractor = TaskInteractor(repository: localRepository)
        deleteInteractor.deleteTask(task)
        updateNoTasksState()
        if currentTasks.count == 0 {
            let reader = ReadDaysInteractor(repository: localRepository)
            userInterface?.showDates(reader.weeks())
        }
    }
}
