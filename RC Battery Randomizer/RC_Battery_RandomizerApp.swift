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

extension NSImage {
    // Static function allows this to be a class-level function instead of instance-level
    static func batteryIcon(percentage: Int) -> NSImage? {
        //
        guard let baseSymbol = NSImage(systemSymbolName: "battery.0percent", accessibilityDescription: "Battery") else {
            return nil
        }
        let baseConfig = NSImage.SymbolConfiguration(
            pointSize: 19.5,
            weight: .light
        )
        let dimWhite: NSColor = .systemFill.withAlphaComponent(0.75)
        let colorConfig = NSImage.SymbolConfiguration(paletteColors: [dimWhite])
        let combinedConfig = baseConfig.applying(colorConfig)
        guard let configuredSymbol = baseSymbol.withSymbolConfiguration(combinedConfig) else {
            return nil
        }
        let size = configuredSymbol.size
        
        let newImage = NSImage(size: size)
        
        // TODO: Why lockFocus?
        newImage.lockFocus()
        
        NSColor.white.setFill()
        configuredSymbol.draw(at: .zero, from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        
        // TODO: Why defer?
        defer { newImage.unlockFocus() }
        
        let fillStartX = 4.5
        let fillEndX = size.width - 8.0
        let fillY = 3.5
        let fillHeight = size.height - 7.75
        let fillWidth = (fillEndX - fillStartX) * CGFloat(min(100, max(0, percentage))) / 100.0

        NSGraphicsContext.current?.saveGraphicsState()
        
        
        // Clear the background for when percent changes
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        NSColor.white.setFill()
        
        let fillRect = NSRect(x: fillStartX, y: fillY, width: fillWidth, height: fillHeight)
        let path = NSBezierPath(roundedRect: fillRect, xRadius: 2.0, yRadius: 2.0)
        path.addClip()
        
        fillRect.fill()
        
        NSGraphicsContext.current?.restoreGraphicsState()
        
        return newImage
    }
}

class RCBatteryAppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var currentLevel: Int = 100
    var timer: Timer?
    
    func generateTitle(button: NSStatusBarButton) -> Void {
        button.font = .menuBarFont(ofSize: 11) // Similar to official battery bar
        button.title = "\(currentLevel)%"
    }
    
    @objc func handleClick(_ sender: NSStatusBarButton) {
    }
    
    func updateButton(button: NSStatusBarButton) -> Void {
        generateTitle(button: button)
        button.image = NSImage.batteryIcon(percentage: currentLevel)
    }
    
    func updateBatteryLevel(button: NSStatusBarButton) -> Void {
        currentLevel -= 1
        updateButton(button: button)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            if (timer == nil) {
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                    if self.currentLevel > 0 {
                        self.updateBatteryLevel(button: button)
                    } else {
                        self.currentLevel = 100
                        self.timer?.invalidate()
                        self.timer = nil
                    }
                })
            }
            updateButton(button: button)
            button.image?.isTemplate = true // PRESENTATION: Allows image to change color dynamically
            button.imagePosition = .imageRight
            button.action = #selector(handleClick(_:))
            button.target = self
            
            
        }
    }
}

