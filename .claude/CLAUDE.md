# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Personal keyboard binding mappings for [Magen](https://github.com/pshirshov/magen) — generates IDE-specific keybinding configs (IntelliJ IDEA XML, VSCode JSON, Zed JSON) from unified YAML source files.

## Build & Generate

Requires [Nix](https://nixos.org/) with flakes enabled. Uses direnv for automatic environment setup.

```sh
nix develop                              # enter dev shell (provides magen CLI)
magen generate --scheme idea-macos       # generate and install into IDE config directories
magen render --scheme idea-macos         # render into output/ directory only (no install)
```

The `MAGEN_MAPPINGS_PATH` env var is set to `./mappings` automatically by the dev shell (see `.envrc` and `flake.nix` shellHook).

There are no tests or linters — validation is done by running `magen generate --scheme idea-macos` and reviewing output.

## Architecture

### Mapping files (`mappings/idea-macos/`)

All YAML source files live under `mappings/idea-macos/`. Each file groups bindings by domain:

- **Top-level files** (e.g. `edit.yaml`, `navigation.yaml`, `cursor.yaml`) — cross-IDE mappings shared across IntelliJ, VSCode, and Zed
- **`idea/`** — IntelliJ-only overrides and additions (e.g. `idea/scala.yaml`)
- **`vscode/`** — VSCode-only mappings (e.g. `vscode/list.yaml`, `vscode/terminal.yaml`)
- **`generic/keys.yaml`** — reusable key aliases referenced via `${key.name}` syntax

### Output

Generated files are installed directly into IDE config directories:
- `~/Library/Application Support/Code/User/keybindings.json` — VSCode
- `~/Library/Application Support/JetBrains/IntelliJIdea*/keymaps/Magen-idea-macos.xml` — IntelliJ IDEA
- `~/.config/zed/keymap.json` — Zed

Also written to `output/` (gitignored) for review.

## Magen YAML Syntax Reference

### Entry structure

Every YAML file has a top-level `mapping:` list. Each entry:

```yaml
mapping:
  - id: "UniqueActionId"
    binding:
      macos: "meta+[KeyF]"       # cmd+F on macOS
      default: "ctrl+[KeyF]"     # ctrl+F on other platforms
    idea:
      action: "IdeaActionName"
    vscode:
      action: "vscode.command.name"
      context: ["when clause expression"]
    zed:
      action: "zed::ActionName"
      context: ["ZedContext"]
```

### Binding formats

**Platform-specific** — use `macos:` / `default:` keys:
```yaml
binding:
  macos: "meta+[KeyF]"
  default: "ctrl+[KeyF]"
```

**Cross-platform** — flat list (same key everywhere):
```yaml
binding:
  - "alt+[F12]"
```

**Multiple bindings per platform:**
```yaml
binding:
  macos:
    - "meta+[right]"
    - "[end]"
    - "ctrl+[KeyE]"
  default:
    - "[end]"
```

### Key code reference

Modifiers: `meta+` (cmd), `ctrl+`, `alt+`, `shift+` — combinable: `ctrl+shift+[KeyF]`

Letters: `[KeyA]` through `[KeyZ]`
Digits: `[Digit0]` through `[Digit9]`
Bare digits also work for some bindings: `"meta+0"`, `"ctrl+shift+5"`

Function keys: `[F2]`, `[F3]`, `[F7]`, `[F8]`, `[F9]`, `[F12]`

Navigation: `[left]`, `[right]`, `[up]`, `[down]`, `[home]`, `[end]`, `[pageup]`, `[pagedown]`

Editing: `[enter]`, `[escape]`, `[tab]`, `[Backspace]`, `[delete]`, `[Space]`, `[Insert]`

Symbols: `[Slash]`, `[Backslash]`, `[Period]`, `[Comma]`, `[Equal]`, `[Minus]`, `[Backquote]`, `[DIVIDE]`, `[MULTIPLY]`

Chord bindings (two-step): `"ctrl+[KeyK] ctrl+[KeyI]"`

Arrow aliases (used in quickinput.yaml): `[ArrowLeft]`, `[ArrowRight]`, `[ArrowUp]`, `[ArrowDown]`

### Key alias references

Defined in `generic/keys.yaml` and referenced with `${name}`:
```yaml
# generic/keys.yaml
keys:
  select.all: "meta+[KeyA]"

# usage in mappings
binding:
  - "${select.all}"
```

### IDE-specific fields

**IntelliJ IDEA** (`idea:`):
```yaml
idea:
  action: "EditorDeleteLine"
```

**VSCode** (`vscode:`):
```yaml
vscode:
  action: "editor.action.deleteLines"
  context: ["textInputFocus && !editorReadonly"]   # optional 'when' clause
  args:                                             # optional command arguments
    text: "\u001b[13;2u"
```

Context is a list of strings — each becomes a VSCode `when` clause. Multiple entries create separate keybinding entries for the same key+action.

**Zed** (`zed:`):
```yaml
zed:
  action: "editor::DeleteLine"
  context: ["Editor"]       # Zed context (Editor, Workspace, Pane, Terminal, etc.)
```

### Marking unsupported actions

When an IDE doesn't support a particular action:
```yaml
idea:
  missing: true
```

This is required for every IDE in the entry — magen validates that all three targets are declared.

### VSCode context patterns

Common context clauses used in this repo:
- `textInputFocus` — editor or terminal has focus (broad)
- `editorFocus` — editor specifically has focus (excludes terminal)
- `editorTextFocus` — text area of editor has focus
- `terminalFocus` — terminal panel has focus
- `terminalFocusInAny` — any terminal-related element has focus
- `terminalFindVisible` / `terminalFindInputFocused` — terminal find widget state
- `listFocus` — tree/list widget has focus
- `inQuickInput` — quick pick/command palette is open
- `suggestWidgetVisible` — autocomplete popup is visible
- Negation with `!`: `!editorReadonly`, `!terminalFocus`
- Combine with `&&`: `editorFocus && findWidgetVisible`
- Alternatives with `||`: `editorFocus || editorIsOpen`

### Magen behavior: VSCode default negation

Magen strips all conflicting VSCode default keybindings by generating `-command` entries (prefixed with `-`). If a default terminal/list/widget binding shares a key with a custom mapping, it gets removed. To preserve defaults, they must be explicitly re-added as entries in the YAML (see `vscode/terminal.yaml` for the full set of re-added terminal defaults).
