//
//  PreferencesViewController.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 24/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import Cocoa

extension ButtonClient.State {
    var statusButtonTitle: String {
        switch self {
        case .offline:
            return "Button is offline"
        case .idle:
            return "Run a task"
        case .running:
            return "Running task"
        }
    }
}

class PreferencesViewController: NSViewController {
    var statusButtonTitle: String = "Idle"
    weak var button: ButtonClient? = nil

    @IBOutlet private weak var statusButton: NSButton!
    
    func reloadUI(withButton button: ButtonClient) {
        if view.window != nil {
            statusButton.title = button.state.statusButtonTitle
            statusButton.isEnabled = button.state != .offline
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        guard let button = button else { fatalError("button not set for preferences") }
        reloadUI(withButton: button)
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApp.terminate(sender)
    }

    @IBAction func runTask(_ sender: NSButton) {
        if (sender.title == "Idle") {
            print("Running task")
            button?.runCommand("cd projects; sleep 3")
//            sender.isEnabled = false
            sender.title = "Finish running task"
        } else {
            print("Task finished")
            sender.title = "Idle"
            let finishCommand = FinishCommand()
            finishCommand.execute()
//            sender.isEnabled = true
        }
        sender.sizeToFit()
    }
}

extension PreferencesViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> PreferencesViewController {
        guard let storyboard = NSStoryboard.main else { fatalError("Main Storyboard not found") }
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "PreferencesViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PreferencesViewController else {
            fatalError("Why cant i find PreferencesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
