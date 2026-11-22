# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## [1.0.1](https://github.com/sravioli/stargaze.wz/compare/e3daca4aef11eb9261e0bfc0b45ad0b4331a427d..1.0.1) - 2026-11-22
#### Bug Fixes
- (**state**) keep the old file when the rename fails, remember own stars - ([bc5e5e8](https://github.com/sravioli/stargaze.wz/commit/bc5e5e82bcd1b0f0aaf4c713232a861b91645082)) - sravioli
- (**state**) create the folder with warp and save atomically - ([d71353e](https://github.com/sravioli/stargaze.wz/commit/d71353ec801e1258536ea9df4478b358d9d40bb0)) - sravioli
#### Documentation
- (**readme**) add the coverage badge - ([2f9d98d](https://github.com/sravioli/stargaze.wz/commit/2f9d98dd063947a8b3f0619daccfb29f8532e955)) - sravioli
- add minit.lua for reproducing bugs - ([ef0e3aa](https://github.com/sravioli/stargaze.wz/commit/ef0e3aa48919a6220fb082f1658a57e594aa8297)) - sravioli
#### Continuous Integration
- pass the release tag to the shell through env - ([f2c14a3](https://github.com/sravioli/stargaze.wz/commit/f2c14a32083ebc4d52027ce995bf84457d75ec00)) - sravioli
- release from the pushed tag - ([5a8b369](https://github.com/sravioli/stargaze.wz/commit/5a8b369153df61a97ff415fd40470818182053d4)) - sravioli
- count only the plugin's own files in coverage - ([eb301d6](https://github.com/sravioli/stargaze.wz/commit/eb301d64e42c63ce74a3cd43aafc7dcd09a664aa)) - sravioli
- bump cocogitto/cocogitto-action from 3.11 to 4 in the actions group (#1) - ([ba48000](https://github.com/sravioli/stargaze.wz/commit/ba480001a20fdc61a18363ada8dc61371d219cf1)) - [@sravioli](https://github.com/sravioli)
- adapt workflows to cocogitto-action v4 - ([36e2f5b](https://github.com/sravioli/stargaze.wz/commit/36e2f5bf939ee36afd1a72f1c64595d3adcc5ced)) - sravioli
- bump cocogitto/cocogitto-action from 3.11 to 4 in the actions group - ([e3daca4](https://github.com/sravioli/stargaze.wz/commit/e3daca4aef11eb9261e0bfc0b45ad0b4331a427d)) - dependabot[bot]
#### Refactoring
- (**state**) store state with warp's data_dir, read_file and write_file - ([8f21354](https://github.com/sravioli/stargaze.wz/commit/8f2135478c042943eeae8ad110544ddec50f9167)) - sravioli
- load log and ribbon from warp - ([ce6c169](https://github.com/sravioli/stargaze.wz/commit/ce6c169dfce325705712eb6ff2dc01819080243a)) - sravioli

- - -

## [1.0.0](https://github.com/sravioli/stargaze.wz/compare/dfd408c9e32c775f74e4b69b065899457aff427d..1.0.0) - 2026-11-16
#### Features
- (**api**) star installed plugins after the first window event - ([c1e070d](https://github.com/sravioli/stargaze.wz/commit/c1e070d1944149c32aa531d61e576ea94640fad8)) - sravioli
- (**config**) add option validation - ([7b15bc5](https://github.com/sravioli/stargaze.wz/commit/7b15bc5158e376beca07f55ffb0f1e424f6259c2)) - sravioli
- (**deps**) add dependency loader - ([bfc23d1](https://github.com/sravioli/stargaze.wz/commit/bfc23d1e4f25111cf69b5ffc2d8b3e7ef9f20b64)) - sravioli
- (**github**) star and unstar through the gh CLI - ([4b4a145](https://github.com/sravioli/stargaze.wz/commit/4b4a1451b720590e3af196a3833254fbe4068e76)) - sravioli
- (**logger**) log through log.wz with a wezterm fallback - ([6c0e4eb](https://github.com/sravioli/stargaze.wz/commit/6c0e4ebb1f5bf0679ea462f9842983f4edc0d5af)) - sravioli
- (**plan**) decide which plugins to star and unstar - ([68b958f](https://github.com/sravioli/stargaze.wz/commit/68b958f65c651e0d3f4e59cf77a798dae91d6c43)) - sravioli
- (**state**) remember starred repositories - ([b3c9873](https://github.com/sravioli/stargaze.wz/commit/b3c9873ef720b0841645c64132845ef0cf7c86cd)) - sravioli
#### Documentation
- (**api**) add the API reference - ([bb859b1](https://github.com/sravioli/stargaze.wz/commit/bb859b1ae52a01143815df4cb0c8d014a3607bd8)) - sravioli
- (**readme**) link community files and add dry-run troubleshooting - ([01cd73a](https://github.com/sravioli/stargaze.wz/commit/01cd73a7e83f9bc4d594ecdb823aa30371f98502)) - sravioli
- add community and contribution files - ([2c47a42](https://github.com/sravioli/stargaze.wz/commit/2c47a42949304b054b4ac895b66c19b236ce8611)) - sravioli
#### Build system
- (**changelog**) use the cocogitto changelog format - ([6e22a96](https://github.com/sravioli/stargaze.wz/commit/6e22a96292739397ed6d2ad2db4391938644fce6)) - sravioli
- add cocogitto changelog configuration - ([aa01925](https://github.com/sravioli/stargaze.wz/commit/aa019252d614f08ffea558f69ed8a9c0762e82e0)) - sravioli
- add lint, format and test tooling - ([3edd373](https://github.com/sravioli/stargaze.wz/commit/3edd373f6f253cfab21b82b3467b7da3709cef45)) - sravioli
#### Continuous Integration
- add lint, test, commit and release workflows - ([a3874f2](https://github.com/sravioli/stargaze.wz/commit/a3874f26cbfdecf7893d8a0401366631ec13500c)) - sravioli

- - -

