//
//  RC_Battery_RandomizerApp.swift
//  RC Battery Randomizer
//
//  Created by C Stavridis on 11/19/25.
//

import SwiftUI
import AppKit

@main
struct RC_Battery_RandomizerApp: App {
    
    // Adapt our custom AppDelegate to hook into SwiftUI life cycle
    // This may be an outdated approach consider using ScenePhase instead
    @NSApplicationDelegateAdaptor(RCBatteryAppDelegate.self) var appDelegate
    
    // We have to add a body to conform to the App protocol
    // But it will be empty because this is a chromeless macOS app
    var body: some Scene {}
    
}

class RCBatteryAppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
        
            // TODO: Turn into a dynamic title
            button.title = "100%"
            button.font = .menuBarFont(ofSize: 11) // Similar to battery bar
            
            // TODO: Turn into a dynamic image
            //
            let imageConfig = NSImage.SymbolConfiguration(pointSize: 19, weight: .light)
            let colorConfig = NSImage.SymbolConfiguration(paletteColors: [.yellow, .white.withAlphaComponent(0.55),])
            let combinedConfig = imageConfig.applying(colorConfig)
            let image = NSImage(systemSymbolName: "battery.50percent", accessibilityDescription: "Battery Level")?.withSymbolConfiguration(combinedConfig)
            button.image = image
            button.imagePosition = .imageRight
            button.imageHugsTitle = true
        }
        
        let menu = NSMenu(title: "Battery")
        
        menu.addItem(withTitle: "Battery 25%", action: nil, keyEquivalent: "")
        
        statusItem?.menu = menu
    }
}

