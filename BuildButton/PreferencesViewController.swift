//
//  PreferencesViewController.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 24/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import Cocoa

extension ButtonClient.State {
    var statusLabelTitle: String {
        switch self {
        case .offline:
            return "Button is offline."
        case .idle:
            return "Button is now idle."
        case .running:
            return "Button is currently running a task."
        }
    }
}

class PreferencesViewController: NSViewController {
    var statusButtonTitle: String = "Idle"
    weak var button: ButtonClient? = nil

    @IBOutlet private weak var statusLabel: NSTextField!
    @IBOutlet private weak var statusIcon: NSImageView!
    @IBOutlet private weak var statusButton: NSButton!
    @IBOutlet private weak var textView: NSTextView!

    func reloadUI(withButton button: ButtonClient) {
        if view.window != nil {
            statusLabel.cell?.title = button.state.statusLabelTitle
            statusIcon.image = NSImage(named: NSImage.Name("\(button.state.statusItemIconName)-big"))
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
        print("Task finished")
        let finishCommand = FinishCommand()
        finishCommand.execute()
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
