//
//  AppDelegate.swift
//  StatusBar
//
//  Created by Havil on 07.05.2020.
//  Copyright © 2020 Havil. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {

    var statusItem: NSStatusItem? = nil
    var popover = NSPopover()
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(named: "light")
            button.action = #selector(showConverterVC)
        }
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
          if let strongSelf = self, strongSelf.popover.isShown {
            self!.popover.close()
          }
        }
        
        popover.contentViewController = StatusBarViewController.loadFromNid()
        popover.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func showConverterVC(sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let button = statusItem?.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func popoverDidShow(_ notification: Notification) {
        eventMonitor?.start()
    }
    
    func popoverDidClose(_ notification: Notification) {
        eventMonitor?.stop()
    }
    
}

