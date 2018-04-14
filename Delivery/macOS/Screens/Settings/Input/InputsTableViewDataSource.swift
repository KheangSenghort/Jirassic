//
//  InputsTableViewDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

enum InputType {
    case shell
    case jirassic
    case git
    case jit
    case browser
    static var all: [InputType] = [.shell, .jirassic, .git, .jit, .browser]
}

class InputsTableViewDataSource: NSObject {
    
    fileprivate let tableView: NSTableView
    fileprivate let cells: [InputType] = InputType.all
    var shellCell: ShellCell?
    var jirassicCell: JirassicCell?
    var jitCell: JitCell?
    var gitCell: GitCell?
    var browserCell: BrowserCell?
    
    init (tableView: NSTableView) {
        self.tableView = tableView
        super.init()

        ShellCell.register(in: tableView)
        JirassicCell.register(in: tableView)
        JitCell.register(in: tableView)
        GitCell.register(in: tableView)
        BrowserCell.register(in: tableView)
        
        shellCell = ShellCell.instantiate(in: self.tableView)
        jirassicCell = JirassicCell.instantiate(in: self.tableView)
        jitCell = JitCell.instantiate(in: self.tableView)
        gitCell = GitCell.instantiate(in: self.tableView)
        browserCell = BrowserCell.instantiate(in: self.tableView)
    }

    func showSettingsBrowser (_ settings: SettingsBrowser) {
        browserCell!.showSettings(settings)
    }
    
    func settingsBrowser() -> SettingsBrowser {
        return browserCell!.settings()
    }
}

extension InputsTableViewDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return cells.count
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        let inputType = cells[row]
        switch inputType {
        case .shell:
            return ShellCell.height
        case .jirassic:
            return JirassicCell.height
        case .git:
            return GitCell.height
        case .jit:
            return JitCell.height
        case .browser:
            return BrowserCell.height
        }
    }
}

extension InputsTableViewDataSource: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cell: NSView! = nil
        let outputType = cells[row]
        switch outputType {
        case .shell:
            cell = shellCell!
        case .jirassic:
            cell = jirassicCell!
        case .git:
            cell = gitCell!
        case .jit:
            cell = jitCell!
        case .browser:
            cell = browserCell!
        }
        
        return cell
    }
}
