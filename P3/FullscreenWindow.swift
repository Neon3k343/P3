import SwiftUI
import AppKit

final class FullscreenWindow: NSWindow {
    // Borderless windows can't become key by default, which breaks Esc/keyboard input
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
final class FullscreenController {
    static let shared = FullscreenController()
    private var window: FullscreenWindow?

    var isActive: Bool { window != nil }

    func enter<Content: View>(@ViewBuilder content: () -> Content) {
        guard window == nil,
              let screen = NSApp.keyWindow?.screen ?? NSScreen.main else { return }

        let w = FullscreenWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        w.level = .screenSaver              // above the menu bar
        w.isOpaque = true
        w.hasShadow = false
        w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        w.contentView = NSHostingView(
            rootView: content()
                .ignoresSafeArea()
                .onExitCommand { FullscreenController.shared.exit() }  // Esc
                .onTapGesture { FullscreenController.shared.exit() }   // optional
        )
        w.setFrame(screen.frame, display: true)

        NSApp.presentationOptions = [.hideMenuBar, .hideDock]
        w.makeKeyAndOrderFront(nil)
        window = w
    }

    func exit() {
        NSApp.presentationOptions = []
        window?.orderOut(nil)
        window = nil
    }
}