//
//  JiraTempoCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 31/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class JiraTempoCell: NSTableRowView {
    
    @IBOutlet fileprivate var baseUrlTextField: NSTextField!
    @IBOutlet fileprivate var userTextField: NSTextField!
    @IBOutlet fileprivate var passwordTextField: NSTextField!
    @IBOutlet fileprivate var projectNamePopup: NSPopUpButton!
    @IBOutlet fileprivate var projectIssueNamePopup: NSPopUpButton!
    @IBOutlet fileprivate var progressIndicator: NSProgressIndicator!
    
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    var presenter: JiraTempoPresenterInput = JiraTempoPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseUrlTextField.delegate = self
        userTextField.delegate = self
        passwordTextField.delegate = self
        
        baseUrlTextField.stringValue = localPreferences.string(.settingsJiraUrl)
        userTextField.stringValue = localPreferences.string(.settingsJiraUser)
        passwordTextField.stringValue = KeychainWrapper.standard.string(forKey: "jira_password") ?? ""
        
        projectNamePopup.target = self
        projectNamePopup.action = #selector(JiraTempoCell.projectNamePopupSelected(_:))
        
        projectIssueNamePopup.target = self
        projectIssueNamePopup.action = #selector(JiraTempoCell.projectIssueNamePopupSelected(_:))
        
        (presenter as! JiraTempoPresenter).userInterface = self
        presenter.setupUserInterface()
        presenter.checkCredentials()
    }
    
    func save() {
        localPreferences.set(baseUrlTextField.stringValue, forKey: .settingsJiraUrl)
        localPreferences.set(userTextField.stringValue, forKey: .settingsJiraUser)
        let saveSuccessful: Bool = KeychainWrapper.standard.set(passwordTextField.stringValue, forKey: "jira_password")
        RCLog(saveSuccessful)
    }
    
    @IBAction func projectNamePopupSelected (_ sender: NSPopUpButton) {
        if let title = sender.selectedItem?.title {
            localPreferences.set(title, forKey: .settingsJiraProjectKey)
            presenter.loadProjectIssues(for: title)
        }
    }
    
    @IBAction func projectIssueNamePopupSelected (_ sender: NSPopUpButton) {
        localPreferences.set(sender.selectedItem?.title ?? "", forKey: .settingsJiraProjectIssueKey)
    }
}

extension JiraTempoCell: JiraTempoPresenterOutput {
    
    func enableProgressIndicator (_ enabled: Bool) {
        enabled
            ? progressIndicator.startAnimation(nil)
            : progressIndicator.stopAnimation(nil)
    }
    
    func showProjects (_ projects: [String], selectedProject: String) {
        projectNamePopup.removeAllItems()
        projectNamePopup.addItems(withTitles: projects)
        projectNamePopup.selectItem(withTitle: selectedProject)
    }
    
    func showProjectIssues (_ issues: [String], selectedIssue: String) {
        projectIssueNamePopup.removeAllItems()
        projectIssueNamePopup.addItems(withTitles: issues)
        projectIssueNamePopup.selectItem(withTitle: selectedIssue)
    }
}

extension JiraTempoCell: NSTextFieldDelegate {
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        save()
        guard baseUrlTextField.stringValue != "", userTextField.stringValue != "", passwordTextField.stringValue != "" else {
            return
        }
        presenter.checkCredentials()
    }
}
