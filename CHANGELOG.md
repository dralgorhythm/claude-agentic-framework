# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - Unreleased

### Breaking

- Beads/`bd` CLI dependency removed entirely — task tracking now uses Claude Code's native task list plus GitHub Issues (two-tier convention)
- `.gitattributes` beads merge driver removed
- Init script no longer runs `bd init`

### Changed

- Worker agents pinned to cost-efficient model tiers with least-privilege tool allowlists

<!-- Later PRs: append new Added / Changed / Deprecated / Removed / Fixed / Security entries above this line, keeping the [3.0.0] - Unreleased section open until release. -->
