import SwiftUI
import ApplicationServices

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

@MainActor
private final class RaggyController: ObservableObject {
    @Published private(set) var hasAccessibilityPermission: Bool

    private let keyboardBlocker = KeyboardBlocker()
    private var permissionPollTask: Task<Void, Never>?
    private var isCleaningModeActive = false

    init() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }

    func enterPermissionMode() {
        stopCleaningMode()
        refreshAccessibilityPermission()
        startPermissionPolling()
    }

    func enterCleaningMode() {
        refreshAccessibilityPermission()

        guard hasAccessibilityPermission, !isCleaningModeActive else { return }

        stopPermissionPolling()

        NSApplication.shared.presentationOptions = [
            .hideDock,
            .hideMenuBar,
            .disableAppleMenu,
            .disableHideApplication,
            .disableProcessSwitching
        ]

        isCleaningModeActive = true
        keyboardBlocker.start()
    }

    func stopCleaningMode() {
        keyboardBlocker.stop()
        NSApplication.shared.presentationOptions = []
        isCleaningModeActive = false
    }

    func requestAccessibilityPermission() {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)
        openAccessibilitySettings()
        startPermissionPolling()
    }

    func refreshAccessibilityPermission() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }

    func startPermissionPolling() {
        guard permissionPollTask == nil else { return }

        permissionPollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000)
                self?.refreshAccessibilityPermission()
            }
        }
    }

    func stopPermissionPolling() {
        permissionPollTask?.cancel()
        permissionPollTask = nil
    }

    func prepareForTermination() {
        stopPermissionPolling()
        stopCleaningMode()
    }

    func quit() {
        prepareForTermination()
        NSApplication.shared.terminate(nil)
    }

    private func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}

private struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        FullScreenConfigurationView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class FullScreenConfigurationView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        guard let window else { return }

        window.collectionBehavior.insert(.fullScreenPrimary)
        window.makeKeyAndOrderFront(nil)

        if !window.styleMask.contains(.fullScreen) {
            window.toggleFullScreen(nil)
        }
    }
}

private final class KeyboardBlocker {
    private var localMonitors: [Any] = []
    private var eventTap: CFMachPort?
    private var eventTapSource: CFRunLoopSource?
    private var isBlocking = false

    deinit {
        stop()
    }

    func start() {
        guard localMonitors.isEmpty, eventTap == nil else { return }

        isBlocking = true
        localMonitors = [
            NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged, .systemDefined]) { [weak self] event in
                self?.isBlocking == true ? nil : event
            }
        ].compactMap { $0 }

        startHIDEventTap()
    }

    func stop() {
        isBlocking = false

        localMonitors.forEach(NSEvent.removeMonitor)
        localMonitors.removeAll()

        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }

        if let eventTapSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), eventTapSource, .commonModes)
        }

        if let eventTap {
            CFMachPortInvalidate(eventTap)
        }

        eventTapSource = nil
        eventTap = nil
    }

    private func startHIDEventTap() {
        let eventMask = Self.eventMask(for: [.keyDown, .keyUp, .flagsChanged, systemDefinedCGEventType])
        guard let eventTap = CGEvent.tapCreate(
            tap: hidCGEventTapLocation,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: keyboardBlockerEventTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            isBlocking = false
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        self.eventTap = eventTap
        eventTapSource = source
    }

    private static func eventMask(for eventTypes: [CGEventType]) -> CGEventMask {
        eventTypes.reduce(CGEventMask(0)) { mask, eventType in
            mask | (1 << CGEventMask(eventType.rawValue))
        }
    }

    fileprivate func shouldBlockEvent(_ eventType: CGEventType) -> Bool {
        isBlocking && shouldBlockKeyboardEvent(eventType)
    }
}

private func keyboardBlockerEventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else {
        return Unmanaged.passUnretained(event)
    }

    let keyboardBlocker = Unmanaged<KeyboardBlocker>.fromOpaque(userInfo).takeUnretainedValue()

    if keyboardBlocker.shouldBlockEvent(type) {
        return nil
    }

    return Unmanaged.passUnretained(event)
}

private func shouldBlockKeyboardEvent(_ eventType: CGEventType) -> Bool {
    eventType == .keyDown
        || eventType == .keyUp
        || eventType == .flagsChanged
        || eventType == systemDefinedCGEventType
}

private let hidCGEventTapLocation = CGEventTapLocation(rawValue: 0)!
private let systemDefinedCGEventType = CGEventType(rawValue: 14)!
