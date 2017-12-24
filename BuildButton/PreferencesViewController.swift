//
//  PreferencesViewController.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 24/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    var statusButtonTitle: String = "Idle"

    @IBOutlet private weak var statusButton: NSButton!

    override func viewWillAppear() {
        super.viewWillAppear()
        statusButton.title = statusButtonTitle
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApp.terminate(sender)
    }

    @IBAction func runTask(_ sender: NSButton) {
        if (sender.title == "Idle") {
            print("Running task")
            runCommand("cd projects; sleep 10")
//            sender.isEnabled = false
            sender.title = "Finish running task"
        } else {
            print("Task finished")
            sender.title = "Idle"
            BLEManager.shared.notifyFinishedTask()
//            sender.isEnabled = true
        }
        sender.sizeToFit()
    }
    
    func runCommand(_ command: String) {
        guard let scriptURL = Bundle.main.url(forResource: "run_in_terminal", withExtension: "scpt") else { fatalError("run_in_terminal script not found") }

        let scriptData = try! Data(contentsOf: scriptURL)
        guard var scriptString = String(bytes: scriptData, encoding: .utf8) else { fatalError("failed to read run_in_terminal script") }
        
        let argument = "\(command); osascript -e 'tell application \\\"BuildButton\\\"' -e 'finish' -e 'end tell'"
        scriptString.append("runSimple(\"\(argument)\")")

        guard let script = NSAppleScript(source: scriptString)
            else { fatalError("failed to initialize Apple Script with given source") }

        var error: NSDictionary? = nil
        script.executeAndReturnError(&error)
        if let error = error {
            print("Error while executing Apple Script: \(error)")
        }
    }

}

extension PreferencesViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> PreferencesViewController {
        guard let storyboard = NSStoryboard.main else { fatalError("Main Storyboard not found") }
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "PreferencesViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PreferencesViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
