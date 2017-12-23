//
//  AppDelegate.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 22/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private(set) var bleManager: BLEManager!
    let menuItem: NSMenuItem = {
        let item = NSMenuItem(title: "Idle", action: nil, keyEquivalent: "")
        return item
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.image = NSImage(imageLiteralResourceName: "statusItem")
        let menu = NSMenu()
        menu.addItem(menuItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit(_:)), keyEquivalent: ""))
        statusItem?.menu = menu
        bleManager = BLEManager()
        
        bleManager.buttonDidTrigger = { manager in
            self.menuItem.title = "Finish task"
            self.menuItem.action = #selector(self.finishTask(_:))
        }
    }

    
    @objc private func finishTask(_ sender: NSMenuItem) {
        bleManager.notifyFinishedTask()
        menuItem.title = "Idle"
        menuItem.target = nil
    }
    
    @objc private func quit(_ sender: NSMenuItem) {
        NSApp.terminate(sender)
    }

    private(set) var statusItem: NSStatusItem? = nil
    var isDarkModeOn: Bool = false
}

