# Raggy

Turn your Mac into a calm black slab while you wipe away the fingerprints, crumbs, and mystery smudges.

Raggy is a tiny macOS screen-cleaning app built with SwiftUI. Launch it, grant Accessibility permission, and it jumps into a full-screen black cleaning mode that blocks keyboard input, function keys, and the usual escape hatches that love to interrupt a good polish.

## What It Does

- Goes full-screen with a clean black display
- Hides the Dock and menu bar while cleaning mode is active
- Blocks keyboard events, modifier keys, brightness keys, volume keys, and other system-defined key events
- Guides you through macOS Accessibility permission
- Gives you one obvious way out: `Exit Raggy`

## Why

Because cleaning a Mac screen should not become a slapstick routine where every wipe changes the volume, summons Spotlight, opens Mission Control, and leaves you negotiating with a keyboard that thinks it is helping.

Raggy keeps the machine quiet while the cloth does its thing.

## Requirements

- macOS 14.4 or newer
- Xcode 15 or newer
- Accessibility permission for Raggy

## Getting Started

1. Clone the repo.

   ```sh
   git clone https://github.com/Vida-CruX/Raggy.git
   cd Raggy
   ```

2. Open the project in Xcode.

   ```sh
   open Raggy.xcodeproj
   ```

3. Select the `Raggy` scheme and run the app.

4. When prompted, grant Accessibility permission:

   `System Settings` -> `Privacy & Security` -> `Accessibility` -> enable `Raggy`

5. Return to Raggy and click `Check Again`, or relaunch the app.

## Using Raggy

Once permission is granted, Raggy opens directly into cleaning mode:

- The screen turns black.
- The app enters full screen.
- Keyboard input is blocked.
- The Dock and menu bar stay out of the way.

To leave cleaning mode, click `Exit Raggy`.

## Project Map

```text
Raggy/
├── ContentView.swift       # Permission and cleaning-mode views
├── RaggyApp.swift          # App lifecycle, commands, and full-screen setup
├── RaggyViewModel.swift    # Permission checks and keyboard blocking
├── Raggy.entitlements      # App sandbox entitlement
└── Assets.xcassets         # App assets
```

## How It Works

Raggy uses macOS Accessibility trust checks to make sure it is allowed to intercept keyboard events. When cleaning mode starts, it installs local event monitors and a HID-level event tap, then drops keyboard-related events while the app is active.

It also sets macOS presentation options to hide the Dock, hide the menu bar, disable app hiding, and prevent process switching during the cleaning session.

## Development

Build from Xcode, or from the command line:

```sh
xcodebuild -project Raggy.xcodeproj -scheme Raggy -configuration Debug build
```

The app is intentionally small. The best contributions are the tidy kind:

- Safer permission handling
- Better full-screen behavior
- Clearer user-facing copy
- Tests for lifecycle and controller behavior
- A properly shiny app icon

## Safety Note

Raggy is designed to quit cleanly and remove its event monitors when cleaning mode stops or the app terminates. If you are changing keyboard interception code, test carefully. A screen-cleaning app should be bold enough to block accidental key presses, but polite enough to hand the keyboard back when asked.

## License

No license has been added yet.
