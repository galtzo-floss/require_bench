# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

## [Unreleased]

### Added

- kettle-jem-template-20260720-005 - README Support & Community links now
  include RubyForum.
- kettle-jem-template-20260726-001 - Projects now include YARD lint
  configuration and documentation dependencies so documentation issues fail
  before generated docs are refreshed.
- kettle-jem-template-20260727-001 - Spec harness documentation now lists the
  RSpec helpers provided by `kettle-test`.

### Changed

- kettle-jem-template-20260716-002 - Gemspecs now ship fewer repository-only
  files, reducing package noise for downstream packagers.
- kettle-jem-template-20260720-002 - Development Gemfiles now use the released
  `tree_sitter_language_pack` gem 1.13.3 or newer by default.
- kettle-jem-template-20260725-002 - Version specs now use `anonymous_loader` to
  cover `version.rb` without redefining constants, or are removed when version
  specs are not managed for the project.
- kettle-jem-template-20260801-001 - Generated README gem dashboard links now
  use ClickGems instead of BestGems.

- kettle-jem-template-20260728-001 - Generated Ruby workflows now use clearer
  setup-ruby-flash planning and can prepare appraisal-only jobs without
  installing the main Gemfile bundle.

- Prepare project for kettle-jem templates: updated 12 project files across dependencies (12).

### Deprecated

### Removed

### Fixed

- kettle-jem-template-20260720-003 - StructuredMerge Git diff driver config now
  uses the installed `smorg-rb` driver command.
- kettle-jem-template-20260725-001 - Release pull request branches beginning
  with `feature/release` now run JRuby and TruffleRuby workflows.
- kettle-jem-template-20260726-002 - Generated version files now document their
  version namespace and constants, reducing warning-only YARD lint output.
- kettle-jem-template-20260726-003 - Coverage upload steps now treat Coveralls,
  QLTY, and Codecov as optional, so provider outages do not fail CI when local
  coverage thresholds still pass.
- kettle-jem-template-20260728-002 - Generated RuboCop configs now ignore the
  same `gemfiles/vendor/bundle` tree as `.gitignore`, so vendored dependency
  installs are not reported as project lint debt.
- kettle-jem-template-20260728-005 - VersionGem bootstrap now creates the
  missing canonical version spec when a project only has shim namespace version
  specs.
- kettle-jem-template-20260730-001 - Gemspec package file enumeration now runs
  relative to the gemspec directory, so release package contents stay correct
  even when the gemspec is loaded from another working directory.
- kettle-jem-template-20260801-002 - Generated RSpec helpers now normalize
  managed configuration block bindings structurally, preventing mixed block
  parameter names from producing invalid configuration after a merge.
- kettle-jem-template-20260801-003 - Generated project metadata and
  documentation now normalize configured underscore hostnames to valid
  hyphenated hostnames.
- kettle-jem-template-20260801-004 - Generated organization README logos now
  use GitHub's stable organization avatar endpoint instead of assuming a
  matching Galtzo-hosted asset exists.

- kettle-jem-template-20260728-003 - Generated dep-heads workflows now run
  TruffleRuby jobs with current RubyGems and Bundler, avoiding setup failures
  before the test suite starts.
- kettle-jem-template-20260728-004 - Generated dep-heads workflows now use the
  setup-ruby Bundler install path for direct appraisal Gemfiles, avoiding rv
  lockfile parser failures on Git and path dependencies.
- kettle-jem-template-20260729-001 - Generated JRuby 9.4 workflows now use the
  legacy manual bundle install path, avoiding setup-time Bundler full-index
  failures against `gem.coop`.

- kettle-jem-template-20260802-001 - Devcontainer JSON files now merge as JSONC,
  preserving comments and trailing commas during template updates.

- Fix coverage configuration loading before the spec helper initializes its run-mode constants.

- Make require timing recursion protection thread-local and preserve lazy-loaded dependencies.

### Security

## [1.0.4] 2023-10-10
### Added
- Minimum Ruby version @ 2.2.0
- Support tracking `load` in addition to `require`!
- More tests
- Better documentation
- New ENV control variables
  - wrap/log load in addition to require
    - ENV['REQUIRE_BENCH_TRACKED_METHODS']
  - rescue errors
    - ENV['REQUIRE_BENCH_RESCUED_CLASSES']
  - log start
    - ENV['REQUIRE_BENCH_LOG_START']
  - load/require timeout
    - ENV['REQUIRE_BENCH_TIMEOUT']
  - A pattern for paths that should be included/tracked
    - ENV['REQUIRE_BENCH_INCLUDE_PATTERN']
  - Should grouping be by basename or by path?
    - ENV['REQUIRE_BENCH_GROUP_PRECEDENCE']
  - Prefer to not group some pattern (i.e. some libraries)
    - ENV['REQUIRE_BENCH_NO_GROUP_PATTERN']
### Changed
- RequireBench::Version is now RequireBench::VERSION::Version (uses version_gem)
### Fixed
- No RequireBench behavior unless ENV['REQUIRE_BENCH'] == 'true'
- Use `casecmp?` instead of `==` to check ENV variable flags ^

## [1.0.3] 2020-04-08
### Added
- More tests

## [1.0.2] 2020-04-08
### Added
- Improved documentation
- Improved handling of ENV variables

## [1.0.1] 2018-09-21
### Added
- Improved documentation
- MIT license

## [1.0.0] 2018-09-21
### Added
- Initial release

[Unreleased]: https://gitlab.com/pboling/require_bench/-/compare/v1.0.4...HEAD
[1.0.4]: https://gitlab.com/pboling/require_bench/-/compare/v1.0.3...v1.0.4
[1.0.3]: https://gitlab.com/pboling/require_bench/-/compare/v1.0.2...v1.0.3
[1.0.2]: https://gitlab.com/pboling/require_bench/-/compare/v1.0.1...v1.0.2
[1.0.1]: https://gitlab.com/pboling/require_bench/-/compare/v1.0.0...v1.0.1
[1.0.0]: https://gitlab.com/pboling/require_bench/-/compare/67e03119ddb8be7b04ae7fd12da62d0ea5b6fb74...v1.0.0
