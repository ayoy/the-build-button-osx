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

class PreferencesViewController: NSViewController, NSTextViewDelegate {
    var statusButtonTitle: String = "Idle"
    var commands: String = ""
    weak var button: ButtonClient? = nil
    var commandsDidChange: (([String]) -> Void)? = nil

    @IBOutlet private weak var statusLabel: NSTextField!
    @IBOutlet private weak var statusIcon: NSImageView!
    @IBOutlet private weak var statusButton: NSButton!
    @IBOutlet private weak var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.string = commands
        textView.font = NSFont(name: "Menlo Regular", size: 12)
    }

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
    
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        print(textView.string)
        commandsDidChange?(textView.string.components(separatedBy: "\n").filter({!$0.isEmpty}))
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
