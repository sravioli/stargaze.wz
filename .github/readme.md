# stargaze.wz [![Release](https://img.shields.io/github/v/release/sravioli/stargaze.wz?style=flat&label=Release&logo=github)](https://github.com/sravioli/stargaze.wz/releases/latest)

[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/stargaze.wz/tests.yaml?style=flat&label=Tests&logo=githubactions)](https://github.com/sravioli/stargaze.wz/actions/workflows/tests.yaml)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/stargaze.wz/lint.yaml?style=flat&label=Lint&logo=githubactions)](https://github.com/sravioli/stargaze.wz/actions/workflows/lint.yaml)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/stargaze.wz?style=flat&label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/stargaze.wz)
[![Code license](https://img.shields.io/badge/Code-GPL--2.0-blue?style=flat&logo=gnu)](../LICENSE)
[![Docs license](https://img.shields.io/badge/Docs-CC_BY--NC_4.0-blue?style=flat&logo=creativecommons)](../LICENSE-DOCS)

Star the [WezTerm](https://wezterm.org/) plugins you use. Inspired by
[thanks.nvim](https://github.com/jsongerber/thanks.nvim).

Stargaze stars every GitHub plugin WezTerm has installed, once, with the
[GitHub CLI](https://cli.github.com/). It can unstar what you later uninstall.

[Quick start](#quick-start) · [Configuration](#configuration) · [API reference](#api-reference) · [Troubleshooting](#troubleshooting) · [Contributing](#contributing) · [License](#license)

## Quick start

### Requirements

You need WezTerm [`20230320-124340-559cb7b0`](https://wezterm.org/config/lua/wezterm.plugin/require.html)
or newer and the [`gh`](https://cli.github.com/) CLI, logged in with
`gh auth login`. Stargaze loads
[warp.wz](https://github.com/sravioli/warp.wz) and
[warden.wz](https://github.com/sravioli/warden.wz) itself, and uses
[log.wz](https://github.com/sravioli/log.wz) when it is installed.

### Install and run

Put this in `wezterm.lua`:

```lua
local wezterm = require "wezterm"
local stargaze = wezterm.plugin.require "https://github.com/sravioli/stargaze.wz"

stargaze.setup {}
```

Five seconds after the first window appears, Stargaze stars each installed
GitHub plugin it has not starred yet. It runs once per WezTerm process.

Only `https://github.com/owner/repo` plugins count. `file://`, SSH and other
hosts are skipped. A repository you already starred is left alone and never
unstarred by Stargaze.

## Configuration

### Example

```lua
stargaze.setup {
  ignore = { repos = { "owner/private.wz" }, authors = { "someone" } },
  unstar_on_uninstall = true,
  dry_run = false,
}
```

### Options

| Option                | Default  | Meaning                                                                 |
| --------------------- | -------- | ----------------------------------------------------------------------- |
| `ignore.repos`        | `{}`     | `owner/name` repositories to never star or unstar.                      |
| `ignore.authors`      | `{}`     | Owners to never star or unstar.                                         |
| `unstar_on_uninstall` | `false`  | Unstar repositories Stargaze starred once they are no longer installed. |
| `dry_run`             | `false`  | Only log what would be starred or unstarred.                            |
| `delay_seconds`       | `5`      | Wait after the first window event before running.                       |
| `state_file`          | data dir | Where starred repositories are remembered.                              |
| `validate`            | `true`   | Set `false` to skip validation and never load warden.                   |

Invalid options are logged and leave Stargaze off. Unknown options warn.

### State

Stargaze remembers what it starred, and which plugins you had starred
yourself (so GitHub is not asked about them again), in
`wezterm/stargaze.wz/state.json` under
`$XDG_DATA_HOME` (default `~/.local/share`), or `%LOCALAPPDATA%` on Windows,
next to where WezTerm keeps its plugins, never in the config directory.
Delete the file to forget everything. The next run re-checks each plugin and
still skips ones you starred yourself.

## API reference

The [API reference](../docs/api.md) lists every function, method, and value
with its parameters and return values. It is generated from the LuaLS
annotations in `plugin/`, so it matches the code. Its sections are
[stargaze](../docs/api.md#stargaze) and [Types](../docs/api.md#types).

- `setup(opts?)` resolves options and schedules one pass. It returns `false`
  when options are invalid or warp.wz cannot load.
- `run(cfg?)` runs a pass now, using the options from `setup`.

## Troubleshooting

### Nothing is starred

Run `gh auth status`. Without a login Stargaze logs one warning and stops.
Set `dry_run = true` and open the debug overlay (`Ctrl+Shift+L`) to see what
it would do.

### Dry run prints nothing

A dry run logs at `INFO` level. If log.wz is installed, its threshold must be
`INFO` or lower when Stargaze's `setup` runs, because the logger keeps the
threshold it saw at that moment. Another plugin that calls `log.setup` later
can raise it again. The pass runs once per WezTerm process, so restart
WezTerm instead of reloading the config to see it again.

### A plugin is missing from the list

Only plugins WezTerm has already fetched are listed by
`wezterm.plugin.list()`, and only GitHub HTTPS URLs are kept.

## Contributing

Questions, bug reports and feature requests go in the
[issue tracker](https://github.com/sravioli/stargaze.wz/issues/new/choose).
Report security problems as described in the
[security policy](SECURITY.md). Everyone taking part follows the
[code of conduct](code_of_conduct.md).

### Development

Run these from the repository root, with Lua 5.4 and the tools installed.
Specs expect a `warden.wz` checkout next to this one.

```sh
busted --verbose
luacheck plugin spec
selene --display-style=quiet plugin
stylua --check plugin spec
```

Specs mock `gh`, timers and events, so nothing touches GitHub. Read the
[contribution guide](contributing.md) before opening a pull request. Use
Conventional Commits and keep documentation changes separate from code.

## License

Code: [GNU GPL v2](../LICENSE). Documentation:
[CC BY-NC 4.0](../LICENSE-DOCS). Preserve existing attribution.
