## Summary

<!-- What changed in stargaze.wz and why. Link related issues: Fixes #123 -->

## Type

- [ ] Bug fix
- [ ] Feature
- [ ] Documentation
- [ ] Other (refactor, CI, chore)

## Details

<!--
Fill in what applies, delete the rest.
- Bug fix: smallest setup that reproduces it, and the root cause. Common areas:
  plugin discovery, repository parsing, ignore rules, state persistence, `gh` invocation, option validation.
- Feature: API sketch and behavior, including defaults and failure cases.
- Documentation: files and examples changed.
-->

## Compatibility

- [ ] Non-breaking
- [ ] Breaking (describe the migration path)

## Checklist

- [ ] Tests added or updated (bug fixes include a regression test), or not
      applicable.
- [ ] `.github/readme.md` and annotations updated for public API or default
      changes.
- [ ] `gh` calls stay out of config evaluation (they run after the first window appears).
- [ ] Existing state files still load.
- [ ] The checks in the contributing guide pass, and commits follow
      Conventional Commits.
