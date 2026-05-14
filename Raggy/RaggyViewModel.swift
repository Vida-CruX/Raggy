import SwiftUI
import ApplicationServices
import Foundation

@MainActor
final class RaggyController: ObservableObject {
    @Published private(set) var hasAccessibilityPermission: Bool

    private let isRunningForPreview: Bool
    private let keyboardBlocker = KeyboardBlocker()
    private let notificationCenterGestureBlocker = NotificationCenterGestureBlocker()
    private var permissionPollTask: Task<Void, Never>?
    private var isCleaningModeActive = false

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        isRunningForPreview = environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        hasAccessibilityPermission = isRunningForPreview ? false : AXIsProcessTrusted()
    }

    func enterPermissionMode() {
        stopCleaningMode()
        refreshAccessibilityPermission()

        guard !isRunningForPreview else { return }

        startPermissionPolling()
    }

    func enterCleaningMode() {
        refreshAccessibilityPermission()

        guard !isRunningForPreview, hasAccessibilityPermission, !isCleaningModeActive else { return }

        stopPermissionPolling()

        NSApplication.shared.presentationOptions = [
            .hideDock,
            .hideMenuBar,
            .disableAppleMenu,
            .disableHideApplication,
            .disableProcessSwitching
        ]

        isCleaningModeActive = true
        notificationCenterGestureBlocker.start()
        keyboardBlocker.start()
    }

    func stopCleaningMode() {
        guard !isRunningForPreview else { return }

        keyboardBlocker.stop()
        notificationCenterGestureBlocker.stop()
        NSApplication.shared.presentationOptions = []
        isCleaningModeActive = false
    }

    func requestAccessibilityPermission() {
        guard !isRunningForPreview else { return }

        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)
        openAccessibilitySettings()
        startPermissionPolling()
    }

    func refreshAccessibilityPermission() {
        hasAccessibilityPermission = isRunningForPreview ? false : AXIsProcessTrusted()
    }

    func startPermissionPolling() {
        guard !isRunningForPreview, permissionPollTask == nil else { return }

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

private final class NotificationCenterGestureBlocker {
    private struct PreferenceSnapshot {
        let domain: String
        let value: CFPropertyList?
    }

    private static let preferenceKey = "TrackpadTwoFingerFromRightEdgeSwipeGesture"
    private static let disabledValue = NSNumber(value: 0)
    private static let domains = [
        "com.apple.AppleMultitouchTrackpad",
        "com.apple.driver.AppleBluetoothMultitouch.trackpad"
    ]
    private static let changeNotifications = [
        "com.apple.AppleMultitouchTrackpadDomainDidChangeNotification",
        "com.apple.AppleMenuGesturesDidChangeNotification",
        "com.apple.IOTrackpadPropertyDidChangeNotification"
    ]

    private var snapshots: [PreferenceSnapshot] = []
    private var isBlocking = false

    deinit {
        stop()
    }

    func start() {
        guard !isBlocking else { return }

        snapshots = Self.domains.map { domain in
            PreferenceSnapshot(
                domain: domain,
                value: Self.preferenceValue(in: domain)
            )
        }

        Self.domains.forEach { domain in
            Self.setPreferenceValue(Self.disabledValue, in: domain)
        }

        Self.notifyPreferenceChanges()
        isBlocking = true
    }

    func stop() {
        guard isBlocking else { return }

        snapshots.forEach { snapshot in
            Self.setPreferenceValue(snapshot.value, in: snapshot.domain)
        }

        snapshots.removeAll()
        Self.notifyPreferenceChanges()
        isBlocking = false
    }

    private static func preferenceValue(in domain: String) -> CFPropertyList? {
        CFPreferencesCopyValue(
            preferenceKey as CFString,
            domain as CFString,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )
    }

    private static func setPreferenceValue(_ value: CFPropertyList?, in domain: String) {
        CFPreferencesSetValue(
            preferenceKey as CFString,
            value,
            domain as CFString,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )
        CFPreferencesSynchronize(
            domain as CFString,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )
    }

    private static func notifyPreferenceChanges() {
        changeNotifications.forEach { notificationName in
            DistributedNotificationCenter.default().postNotificationName(
                Notification.Name(notificationName),
                object: nil,
                userInfo: nil,
                deliverImmediately: true
            )
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
