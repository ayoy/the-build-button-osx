//
//  AppDelegate.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 22/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, BLEManagerDelegate {

    private let popover = NSPopover()
    private(set) var statusItem: NSStatusItem! = nil
    private var eventMonitor: EventMonitor! = nil
    private lazy var preferencesViewController: PreferencesViewController = {
        let vc = PreferencesViewController.freshController()
        vc.button = self.button
        return vc
    }()

    private let button = ButtonClient()
    private(set) var bleManager: BLEManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.image = NSImage(named: NSImage.Name("offline"))
        statusItem?.button?.action = #selector(togglePopover(_:))

        popover.contentViewController = preferencesViewController
        
        bleManager = BLEManager(delegate: self)

        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown])
        { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
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
    
    // MARK: - BLEManagerDelegate
    
    func buttonDidConnect(_ manager: BLEManager) {
        button.state = .idle
        statusItem?.image = NSImage(named: NSImage.Name(button.state.statusItemIconName))
        preferencesViewController.reloadUI(withButton: button)
    }

    func didStartScanningForButton(_ manager: BLEManager) {
    }
    
    func didStopScanningForButton(_ manager: BLEManager) {
    }
    
    func buttonDidDisconnect(_ manager: BLEManager) {
        button.state = .offline
        statusItem?.image = NSImage(named: NSImage.Name(button.state.statusItemIconName))
        preferencesViewController.reloadUI(withButton: button)
    }
    
    func buttonPushed(_ manager: BLEManager) {
        button.state = .running
        statusItem?.image = NSImage(named: NSImage.Name(button.state.statusItemIconName))
        preferencesViewController.statusButtonTitle = "Finish running task"
        preferencesViewController.reloadUI(withButton: button)
        button.runCommand("cd projects && sleep 7")
//        button.runCommand("cd work/Base-iOS-client && bundle exec fastlane hockeyapp version:3.5.2_rc2")
    }
    
    func buttonDidFinishTask(_ manager: BLEManager) {
        button.state = .idle
        statusItem?.image = NSImage(named: NSImage.Name(button.state.statusItemIconName))
        preferencesViewController.reloadUI(withButton: button)
    }
}
