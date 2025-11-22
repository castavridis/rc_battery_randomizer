//
//  RC_Battery_RandomizerApp.swift
//  RC Battery Randomizer
//
//  Created by C Stavridis on 11/19/25.
//

import SwiftUI
import AppKit

struct RC_Battery_RandomizerApp_Clickable: App {
    
    // Adapt our custom AppDelegate to hook into SwiftUI life cycle
    // This may be an outdated approach consider using ScenePhase instead
    @NSApplicationDelegateAdaptor(RCBatteryClickableAppDelegate.self) var appDelegate
    
    // We have to add a body to conform to the App protocol
    // But it will be empty because this is a chromeless macOS app
    var body: some Scene {}
    
}

class RCBatteryClickableAppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var currentStatus: BatteryStatus?
    
    struct BatteryDisplayData: Hashable {
        var icon: String
        var colors: [NSColor]
        var minLevel: Int?
    }
    enum BatteryStatus: CaseIterable {
        case charging, full, high, medium, low, empty
        func displayData () -> BatteryDisplayData {
            switch self {
            case .charging:
                return BatteryDisplayData(icon: "battery.100percent.bolt", colors: [.systemFill, .systemFill, .systemGreen], minLevel: nil)
            case .full:
                return BatteryDisplayData(icon: "battery.100percent", colors: [.systemGreen], minLevel: 100)
            case .high:
                return BatteryDisplayData(icon: "battery.75percent", colors: [.systemGreen], minLevel: 75)
            case .medium:
                return BatteryDisplayData(icon: "battery.50percent", colors: [.systemYellow], minLevel: 50)
            case .low:
                return BatteryDisplayData(icon: "battery.25percent", colors: [.systemRed], minLevel: 25)
            case.empty:
                return BatteryDisplayData(icon: "battery.0percent", colors: [.systemFill], minLevel: 0)
            }
        }
    }
    
    func generateTitle(button: NSStatusBarButton, type: BatteryStatus) -> Void {
        let data: BatteryDisplayData = type.displayData()
        let minLevel = data.minLevel
        if let minLevel {
            button.font = .menuBarFont(ofSize: 11) // Similar to official battery bar
            button.title = "\(minLevel)%"
        }
    }
    
    func generateImage(button: NSStatusBarButton, type: BatteryStatus) -> Void {
        let data: BatteryDisplayData = type.displayData()
        let imageConfig = NSImage.SymbolConfiguration(pointSize: 20, weight: .ultraLight)
        let colorConfig = NSImage.SymbolConfiguration(paletteColors: data.colors)
        let combinedConfig = imageConfig.applying(colorConfig)
        let image = NSImage(systemSymbolName: data.icon, accessibilityDescription: "Battery Level")?.withSymbolConfiguration(combinedConfig)
        button.image = image
        button.image?.isTemplate = true // enable icon to update color with the rest of the status bar, easily
        button.imagePosition = .imageRight // set icon to the right of the text, like the official layout, applying .rightToLeft to the button causes the icon to switch it's display based on the localization
        button.imageHugsTitle = true
    }
    
    @objc func handleClick(_ sender: NSStatusBarButton) {
        let index = BatteryStatus.allCases.firstIndex(of: currentStatus ?? .charging) ?? 0
        let limit = BatteryStatus.allCases.count
        let newType = BatteryStatus.allCases[(index + 1) % limit]
        updateButton(button: sender, type: newType)
    }
    
    func updateButton(button: NSStatusBarButton, type: BatteryStatus) -> Void {
        generateTitle(button: button, type: type)
        generateImage(button: button, type: type)
        currentStatus = type
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.action = #selector(handleClick(_:))
            button.target = self
            updateButton(button: button, type: .full)
        }
    }
}

