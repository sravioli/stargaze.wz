# Changelog

All notable changes to this project are documented here. The format follows
[Conventional Commits](https://www.conventionalcommits.org/) and versions are
managed with [Cocogitto](https://docs.cocogitto.io/).

## Unreleased

### Features

- Stars the GitHub plugins WezTerm has installed, once, through the `gh` CLI.
- Skips `file://`, SSH and non-GitHub plugins.
- Never records (or later unstars) repositories you starred yourself.
- Optional `unstar_on_uninstall` and a `dry_run` mode.
- `ignore.repos` and `ignore.authors`.
- Remembers its work in the user data directory, outside the config directory.
- Options validated with warden.wz; logs through log.wz when available.
