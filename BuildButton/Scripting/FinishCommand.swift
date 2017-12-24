//
//  FinishCommand.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 24/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import Cocoa

class FinishCommand: NSScriptCommand
{
    override func performDefaultImplementation() -> Any? {
        BLEManager.shared.notifyFinishedTask()
        return nil
    }
}
