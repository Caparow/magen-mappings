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

## Usage

Requires [Nix](https://nixos.org/) with flakes enabled.

```sh
# enter dev shell (provides magen CLI)
nix develop

# generate output configs
magen generate
```
