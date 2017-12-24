//
//  PreferencesViewController.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 24/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet private(set) weak var statusButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        statusButton.title = "Idle"
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApp.terminate(sender)
    }

    @IBAction func runTask(_ sender: NSButton) {
        if (sender.title == "Idle") {
            print("Running task")
//            sender.isEnabled = false
            sender.title = "Finish running task"
        } else {
            print("Task finished")
            sender.title = "Idle"
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
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
