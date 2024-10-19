//
//  AppDelegate.swift
//  Audio Transcription App
//
//  Created by Jani Pasanen on 2024-10-18.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Restore the saved window position and size if available
        let windowX = UserDefaults.standard.double(forKey: "windowX")
        let windowY = UserDefaults.standard.double(forKey: "windowY")
        let windowWidth = UserDefaults.standard.double(forKey: "windowWidth")
        let windowHeight = UserDefaults.standard.double(forKey: "windowHeight")
        
        // Set default dimensions if there are no saved values
        let windowRect = NSRect(
            x: windowX != 0 ? windowX : 0,
            y: windowY != 0 ? windowY : 0,
            width: windowWidth != 0 ? windowWidth : 480,
            height: windowHeight != 0 ? windowHeight : 300
        )

        // Create the window and set the content view
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Save the window's current position and size before quitting
        if let frame = window?.frame {
            UserDefaults.standard.set(frame.origin.x, forKey: "windowX")
            UserDefaults.standard.set(frame.origin.y, forKey: "windowY")
            UserDefaults.standard.set(frame.size.width, forKey: "windowWidth")
            UserDefaults.standard.set(frame.size.height, forKey: "windowHeight")
        }
    }

    // Quit the app when the last window is closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

