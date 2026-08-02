# frozen_string_literal: true

# Config for development dependencies of this library
# i.e., not configured by this library
#
# SimpleCov & related config (must run BEFORE any other requires)
# NOTE: Gemfiles for non-coverage appraisals may not have kettle-soup-cover.
#       The rescue LoadError handles that scenario.
begin
  require "kettle-soup-cover"
  if Kettle::Soup::Cover::DO_COV
    # Requiring simplecov loads the project-local `.simplecov`.
    require "simplecov"
    require "kettle/soup/cover/config"
    SimpleCov.start
  end
rescue LoadError => error
  # check the error message and re-raise when unexpected
  raise error unless error.message.include?("kettle")
end

# External RSpec & related config
require "kettle/test/rspec"
# `kettle/test/rspec` installs harness helpers documented in spec/README.md.
require "silent_stream"
require "colorize"
require "lucky_case"

DEBUG = ENV.fetch("DEBUG", nil) == "true"

# external gems
require "version_gem/ruby"
require "version_gem/rspec"

# RSpec Configs
require "config/rspec/rspec_core"
require "config/rspec/rspec_block_is_expected"

# Constrain which workflow / matrix code coverage will run in for CI.
engine = "ruby"
major = 3
minor = 2
version = "#{major}.#{minor}"
gte_min = VersionGem::Ruby.gte_minimum_version?(version, engine)
actual_minor = VersionGem::Ruby.actual_minor_version?(major, minor, engine)

debugging = gte_min && DEBUG

# Setting CI_CODECOV=true will turn on coverage locally.
IS_CI = ENV.fetch("CI", "false").casecmp?("true")
RUN_COVERAGE = ENV.fetch("CI_CODECOV", "false").casecmp?("true") && (!IS_CI || gte_min)
ALL_FORMATTERS = ENV.fetch("COVER_ALL", "false").casecmp?("true") && (!IS_CI || actual_minor)

if DEBUG
  if debugging
    require "debug"
  elsif VersionGem::Ruby.gte_minimum_version?(version, "jruby")
    require "pry-debugger-jruby"
  end
end

# Load Code Coverage as the last thing before this gem
if RUN_COVERAGE
end

# The gem does nothing unless this variable is set.
ENV["REQUIRE_BENCH"] = "true"
ENV["REQUIRE_BENCH_SKIP_PATTERN"] = "skipped_bird|skipped_nested_bird|skipped|nested/ignored"
ENV["REQUIRE_BENCH_INCLUDE_PATTERN"] =
  "ostruct|logged_tiger|logged_skipped_lion|logged_duck|no_group_fox|no_group_cat|grouped|nested/collected"
ENV["REQUIRE_BENCH_NO_GROUP_PATTERN"] = "no_group_fish|no_group_fly|separate|nested/disparate"
# default is "path,basename", which is how Regexp matching works naturally,
#   since the path precedes the basename in any filename string.
ENV["REQUIRE_BENCH_GROUP_PRECEDENCE"] = "basename,path"

require "require_bench"
require "support/helpers/file_factory"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include SilentStream
  config.include FileFactory
end
