//
//  PreferencesViewController.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 24/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func quit(_ sender: Any) {
        NSApp.terminate(sender)
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
