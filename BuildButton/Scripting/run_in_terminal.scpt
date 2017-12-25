#!/usr/bin/osascript

on runInTerminal(command)
  tell application "Terminal"
    activate
    set newTab to do script(command)
  end tell
  return newTab
end runSimple


