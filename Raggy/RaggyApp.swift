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
                    PermissionWindowView(
                        onRequestPermission: controller.requestAccessibilityPermission,
                        onCheckPermission: controller.refreshAccessibilityPermission,
                        onQuit: controller.quit
                    )
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

private final class FullScreenConfigurationView: NSView {
    private var didRequestFullScreen = false

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        guard let window, !didRequestFullScreen else { return }

        didRequestFullScreen = true

        DispatchQueue.main.async { [weak self, weak window] in
            guard let self, let window, self.window === window else { return }

            window.collectionBehavior.insert(.fullScreenPrimary)
            window.makeKeyAndOrderFront(nil)

            if !window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
        }
    }
}
