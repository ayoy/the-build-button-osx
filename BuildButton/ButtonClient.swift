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

    private struct Const {
        static let CommandsKey = "commands"
    }
    
    override init() {
        commands = UserDefaults.standard.stringArray(forKey: Const.CommandsKey) ?? []
    }
    
    var commands: [String] = [] {
        didSet {
            if commands.isEmpty {
                UserDefaults.standard.removeObject(forKey: Const.CommandsKey)
            } else {
                UserDefaults.standard.set(commands, forKey: Const.CommandsKey)
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    var state: State = .offline
    
    
    func runCommand(_ command: String? = nil) {
        var commandToRun = command ?? commands.joined(separator: "; ")
        commandToRun = commandToRun.replacingOccurrences(of: "\"", with: "\\\"");
        guard let scriptURL = Bundle.main.url(forResource: "run_in_terminal", withExtension: "scpt") else { fatalError("run_in_terminal script not found") }
        
        let scriptData = try! Data(contentsOf: scriptURL)
        guard var scriptString = String(bytes: scriptData, encoding: .utf8) else { fatalError("failed to read run_in_terminal script") }
        
        let argument = "\(commandToRun); osascript -e 'tell application \\\"BuildButton\\\"' -e 'finish' -e 'end tell'"
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

