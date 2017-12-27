//
//  ButtonClient.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 24/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import Cocoa

class ButtonClient: NSObject {
    enum State {
        case offline, idle, running

        var statusItemIconName: String {
            switch self {
            case .offline:
                return "offline"
            case .idle:
                return "idle"
            case .running:
                return "running"
            }
        }

    }

    var command: String? = nil
    var state: State = .offline
    
    
    func runCommand(_ command: String) {
        guard let scriptURL = Bundle.main.url(forResource: "run_in_terminal", withExtension: "scpt") else { fatalError("run_in_terminal script not found") }
        
        let scriptData = try! Data(contentsOf: scriptURL)
        guard var scriptString = String(bytes: scriptData, encoding: .utf8) else { fatalError("failed to read run_in_terminal script") }
        
        let argument = "\(command); osascript -e 'tell application \\\"BuildButton\\\"' -e 'finish' -e 'end tell'"
        scriptString.append("runInTerminal(\"\(argument)\")")
        
        guard let script = NSAppleScript(source: scriptString)
            else { fatalError("failed to initialize Apple Script with given source") }
        
        var error: NSDictionary? = nil
        script.executeAndReturnError(&error)
        if let error = error {
            print("Error while executing Apple Script: \(error)")
        }
    }
}

