# Raggy

Turn your Mac into a calm black slab while you wipe away fingerprints, crumbs, and mysterious smudges.

Raggy is a tiny macOS screen-cleaning app built with SwiftUI. Modern MacBooks love reacting to every accidental key press while you clean: brightness changes, volume jumps, Spotlight appears, and Mission Control flies across the screen. Raggy temporarily quiets the machine with a full-screen black cleaning mode that blocks keyboard input, function keys, and other interruptions, so you can properly clean your screen and keyboard in peace.


## Using Raggy

Once permission is granted, Raggy opens directly into cleaning mode:

- The screen turns black.
- The app enters full screen.
- Keyboard input is blocked.
- The Dock and menu bar stay out of the way.

To leave cleaning mode, just click `Exit Raggy`.

## How It Works

Raggy uses macOS Accessibility trust checks to make sure it is allowed to intercept keyboard events. When cleaning mode starts, it installs local event monitors and a HID-level event tap, then drops keyboard-related events while the app is active.

It also sets macOS presentation options to hide the Dock, hide the menu bar, disable app hiding, and prevent process switching during the cleaning session.
