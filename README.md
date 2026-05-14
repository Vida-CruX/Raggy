# Raggy

Raggy is a tiny macOS screen-cleaning app. It opens a full-screen black cleaning mode, blocks keyboard input, hides system chrome, and temporarily disables the Notification Center trackpad edge swipe.

## Features

- Full-screen black cleaning surface
- Dock and menu bar hidden while cleaning
- Keyboard, modifier, function, brightness, volume, and system-key events blocked
- Notification Center trackpad edge swipe disabled during cleaning and restored on exit
- Accessibility permission flow
- Single exit control: `Exit Raggy`

## Requirements

- macOS 14.4 or newer
- Xcode 15 or newer
- Accessibility permission for Raggy

## Run

```sh
open Raggy.xcodeproj
```

Select the `Raggy` scheme and run. When prompted, grant Accessibility permission in:

`System Settings` -> `Privacy & Security` -> `Accessibility`

## Build

```sh
xcodebuild -project Raggy.xcodeproj -scheme Raggy -configuration Debug build
```

## Notes

Raggy uses Accessibility trust checks, local event monitors, and a HID-level event tap to block keyboard-related events. It also snapshots the Notification Center trackpad edge-swipe preference, disables it while cleaning mode is active, and restores the saved value when cleaning mode stops or the app terminates.

## License

No license has been added yet.
