import SwiftUI

@main
struct RaggyApp: App {
    @NSApplicationDelegateAdaptor(RaggyApplicationDelegate.self) private var appDelegate
    @StateObject private var controller = RaggyController()

    var body: some Scene {
        WindowGroup {
            Group {
                if controller.hasAccessibilityPermission {
                    CleaningView {
                        controller.quit()
                    }
                    .background(WindowConfigurator())
                    .onAppear {
                        controller.enterCleaningMode()
                    }
                    .onDisappear {
                        controller.stopCleaningMode()
                    }
                } else {
                    PermissionView(
                        onRequestPermission: controller.requestAccessibilityPermission,
                        onCheckPermission: controller.refreshAccessibilityPermission,
                        onQuit: controller.quit
                    )
                    .background(PermissionWindowConfigurator())
                    .onAppear {
                        controller.enterPermissionMode()
                    }
                    .onDisappear {
                        controller.stopPermissionPolling()
                    }
                }
            }
            .onAppear {
                appDelegate.controller = controller
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                controller.prepareForTermination()
            }
        }
        .commands {
            CommandGroup(replacing: .appTermination) {}
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .windowArrangement) {}
            CommandGroup(replacing: .windowSize) {}
        }
    }
}

@MainActor
private final class RaggyApplicationDelegate: NSObject, NSApplicationDelegate {
    weak var controller: RaggyController?

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        controller?.prepareForTermination()
        return .terminateNow
    }

    func applicationWillTerminate(_ notification: Notification) {
        controller?.prepareForTermination()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

private struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        FullScreenConfigurationView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private struct PermissionWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        PermissionWindowConfigurationView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class PermissionWindowConfigurationView: NSView {
    private var didConfigureWindow = false

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        guard let window, !didConfigureWindow else { return }

        didConfigureWindow = true

        DispatchQueue.main.async { [weak self, weak window] in
            guard let self, let window, self.window === window else { return }

            self.configure(window)
        }
    }

    private func configure(_ window: NSWindow) {
        window.title = "Permission"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = false
        window.isOpaque = true
        window.backgroundColor = .windowBackgroundColor
        window.hasShadow = true

        window.styleMask.remove(.fullSizeContentView)
        window.styleMask.remove(.resizable)

        [
            NSWindow.ButtonType.closeButton,
            .miniaturizeButton,
            .zoomButton
        ].forEach { button in
            window.standardWindowButton(button)?.isHidden = false
        }

        window.contentView?.layoutSubtreeIfNeeded()

        let contentSize = NSSize(
            width: PermissionWindowMetrics.contentSize.width,
            height: PermissionWindowMetrics.contentSize.height
        )

        window.minSize = contentSize
        window.maxSize = contentSize
        window.setContentSize(contentSize)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}

private final class FullScreenConfigurationView: NSView {
    private var didRequestFullScreen = false

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        guard let window, !didRequestFullScreen else { return }

        didRequestFullScreen = true

        DispatchQueue.main.async { [weak self, weak window] in
            guard let self, let window, self.window === window else { return }

            window.minSize = NSSize(width: 1, height: 1)
            window.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            window.styleMask.insert(.resizable)
            window.isOpaque = true
            window.backgroundColor = .black
            window.hasShadow = true
            window.collectionBehavior.insert(.fullScreenPrimary)
            window.makeKeyAndOrderFront(nil)

            if !window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
        }
    }
}
