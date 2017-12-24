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
    
    private let popover = NSPopover()
    private(set) var statusItem: NSStatusItem! = nil
    private var eventMonitor: EventMonitor! = nil
    private let preferencesViewController = PreferencesViewController.freshController()

    private(set) var bleManager: BLEManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.image = NSImage(named: NSImage.Name("statusItem"))
        statusItem?.button?.action = #selector(togglePopover(_:))

        popover.contentViewController = PreferencesViewController.freshController()

        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown])
        { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }

        bleManager = BLEManager()
        
        bleManager.buttonDidTrigger = { manager in
            self.preferencesViewController.statusButton.title = "Finish running task"
        }
    }
    
    @objc private func finishTask(_ sender: NSMenuItem) {
        bleManager.notifyFinishedTask()
    }
    
    @objc private func quit(_ sender: NSMenuItem) {
        NSApp.terminate(sender)
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor.start()
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor.stop()
    }
}

