import AppKit
import MetalKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification)
    {
        // let app = NSApplication.shared
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "My Window"
        window.makeKeyAndOrderFront(nil)

        // Create the MTKView and add it to the window's content view
        let device = MTLCreateSystemDefaultDevice()
        let myGameView = GameView(frame: window.contentView!.bounds, device: device)
        myGameView.autoresizingMask = [.width, .height]
        myGameView.preferredFramesPerSecond = 120
        myGameView.isPaused = false
        myGameView.enableSetNeedsDisplay = false
        window.contentView = myGameView
    }
}