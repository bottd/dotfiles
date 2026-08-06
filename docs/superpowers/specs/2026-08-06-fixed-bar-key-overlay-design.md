# Fixed Bar and Sliding Key Overlay

## Goal

Keep the 32 px taskbar fixed at the bottom of each screen while the command or
launcher menu opened through the key overlay slides out directly above it. The
open menu must be flush with the bar, with no gap.

## Current Behavior

`KeyOverlay` publishes its currently revealed height while its drawer animates.
The visual bar binds its bottom margin to that height, so opening the overlay
pushes the bar upward and closing it pulls the bar back down.

## Design

Define the bar height once in `shell.qml` and use it for all related geometry:

- The invisible panel reserves that height as the bottom work area.
- The visual bar uses that height and remains bottom-anchored with a constant
  zero bottom margin.
- The key overlay window uses that height as its bottom inset, placing the
  window's lower edge at the bar's upper edge.

Keep the drawer's existing local animation unchanged. It moves from its full
height below the overlay window to `y = 0` over 170 ms with `OutCubic` easing.
Because the window is inset above the bar, the drawer appears to slide upward
from behind the fixed bar and finishes flush against it. Closing reverses that
movement without moving the bar.

Remove the `revealedHeight` property from `KeyOverlay` after the bar no longer
consumes it. This eliminates the cross-window animation coupling rather than
leaving an unused layout API.

## Preserved Behavior

- A tapped Super key and the existing command IPC endpoint toggle command mode.
- The launcher IPC endpoint uses the same fixed-bar geometry.
- Focus handling, shortcut inhibition, menu switching, and dismissal behavior
  remain unchanged.
- Disabling animations still snaps the drawer between its hidden and visible
  positions.
- Each screen continues to own its own reserved bar area and visual bar, while
  the key overlay appears only on the selected screen.

## Verification

Run the repository formatting check and evaluate the affected NixOS
configurations. In a live Niri session, toggle both command and launcher modes
and verify that:

- the taskbar never changes position during opening or closing;
- the drawer moves upward and downward while the bar remains visible;
- the fully open drawer is flush with the bar's top edge;
- keyboard focus and Super-key dismissal still work; and
- behavior remains correct on another output when one is available.
