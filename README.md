# magen-bindings

Personal keyboard binding mappings for [Magen](https://github.com/pshirshov/magen) — a tool that generates IDE-specific keybinding configurations from a single declarative YAML source.

## What is this

This repository contains a unified set of keyboard shortcut definitions that get compiled into platform-specific configs for multiple editors:

- **IntelliJ IDEA** (XML keymap)
- **VSCode** (keybindings JSON)
- **Zed** (keybindings JSON)

Instead of maintaining shortcuts separately in each editor, bindings are defined once in YAML and Magen generates the rest.

## Structure

The `MAGEN_MAPPINGS_PATH` environment variable is automatically set to `./mappings` by the dev shell.

The `idea-macos` scheme is composed from two layers:

- `mappings/idea-macos/idea/native-defaults.yaml` fixes the IntelliJ IDEA 2026.2 macOS keyboard and mouse defaults as an explicit baseline. This is required because Magen negates inherited IDEA actions before applying the scheme.
- The remaining mapping files add the shared VSCode/Zed translations and intentional overrides. They are additive, so native IDEA shortcuts remain available unless the baseline itself is changed.

Shared translations preserve IDEA's native aliases when the target editor exposes an equivalent action. When IDEA distinguishes actions that another editor combines—such as Move Line and Move Statement—both IDEA shortcuts map to that editor's single action.

On Linux and Windows, Command-based shortcuts translate to Control. If that would collide with a distinct macOS Control shortcut, the `default` binding uses an explicit alternative so both actions remain addressable.

Keyboard gestures are the exception because Magen cannot encode them. Search Everywhere therefore inherits IDEA's native Double Shift gesture instead of representing it as a two-stroke chord.

Intentional scheme-wide overrides are fixed explicitly in the IDEA baseline. `Cmd+Shift+T` on macOS and `Ctrl+Shift+T` on Linux/Windows reopen the last closed tab; IDEA's native Go to Test and Show Services assignments are removed from that chord.

Clipboard shortcuts follow the cross-platform application convention. `Cmd+Shift+V` on macOS and `Ctrl+Shift+V` on Linux/Windows paste as plain text in editors. IDEA retains Paste from History on `Cmd+Shift+Insert`, terminal contexts retain `Ctrl+Shift+V` for regular paste, and Split Right uses `Cmd+Backslash` or `Ctrl+Backslash`.

## Usage

Requires [Nix](https://nixos.org/) with flakes enabled.

```sh
# enter dev shell (provides magen CLI)
nix develop

# generate output configs
magen generate
```
