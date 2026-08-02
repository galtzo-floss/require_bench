# frozen_string_literal: true

require_relative "require_bench/version"

REQUIRE_BENCH_ENABLED = ENV.fetch('REQUIRE_BENCH', 'false').casecmp?('true')

# STD Libs
if REQUIRE_BENCH_ENABLED
  require 'benchmark'
  require 'timeout'
end

# external libs
require "version_gem"

# This Gem

# Namespace for this gem
module RequireBench
  if REQUIRE_BENCH_ENABLED
    TIMINGS = Hash.new { |h, k| h[k] = 0.0 }
    skips = ENV['REQUIRE_BENCH_SKIP_PATTERN']
    log_start = ENV['REQUIRE_BENCH_LOG_START']
    timeout = ENV.fetch('REQUIRE_BENCH_TIMEOUT', '0').to_i # zero == no timeout, any other number == seconds to wait.
    tracked_methods = ENV.fetch('REQUIRE_BENCH_TRACKED_METHODS', 'require,load').split(',')
    raise ArgumentError, "ENV['REQUIRE_BENCH_TRACKED_METHODS'] is invalid." unless (tracked_methods - %w[load
                                                                                                         require]).empty?

    includes = ENV['REQUIRE_BENCH_INCLUDE_PATTERN']
    no_group = ENV['REQUIRE_BENCH_NO_GROUP_PATTERN']
    group_precedence = ENV.fetch('REQUIRE_BENCH_GROUP_PRECEDENCE', 'path,basename')
    precedence = group_precedence.split(',')
    raise ArgumentError, "ENV['REQUIRE_BENCH_GROUP_PRECEDENCE'] is invalid." unless precedence.sort == %w[basename path]

    rescued_classes = ENV.fetch('REQUIRE_BENCH_RESCUED_CLASSES', '').split(',')

    preferred_grouping = precedence.first
    prefer_not_path = preferred_grouping != 'path' # path correlates to default behavior of regexp matching

    if defined?(ColorizedString)
      require 'require_bench/color_printer'
    else
      require 'require_bench/printer'
    end
    PRINTER = Printer.new

    if rescued_classes.any?
      rescued_classes.map! do |klass|
        Kernel.const_get(klass)
      end
    end
    if skips && !skips.empty?
      skip_pattern = case skips
                     when /,/
                       Regexp.union(*skips.split(','))
                     when /\|/
                       Regexp.union(*skips.split('|'))
                     else
                       Regexp.new(skips)
                     end
      puts "[RequireBench] Using skip pattern: #{skip_pattern}"
    end
    if includes && !includes.empty?
      include_tokens = case includes
                       when /,/
                         includes.split(',')
                       when /\|/
                         includes.split('|')
                       else
                         Array(includes)
                       end
      include_pattern = Regexp.union(*include_tokens)
      include_tokens.reject! { |a| a.match?(%r{/}) } if prefer_not_path
      puts "[RequireBench] Using include pattern: #{include_pattern}"
    end
    if no_group && !no_group.empty?
      no_group_pattern = case no_group
                         when /,/
                           Regexp.union(*no_group.split(','))
                         when /\|/
                           Regexp.union(*no_group.split('|'))
                         else
                           Regexp.new(no_group)
                         end
      puts "[RequireBench] Using no group pattern: #{no_group_pattern}"
    end
    INCLUDE_PATTERN = include_pattern
    INCLUDE_TOKENS = include_tokens
    LOG_START = log_start
    NO_GROUP_PATTERN = no_group_pattern
    PREFER_NOT_PATH = prefer_not_path
    RESCUED_CLASSES = rescued_classes
    SKIP_PATTERN = skip_pattern
    TIMEOUT = timeout
    TRACKED_METHODS = tracked_methods

    def consume_with_timing(type, file, *args)
      $require_bench_semaphore = true
      short_type = type[0]
      ret = nil
      # Not sure if this is actually a useful abstraction...
      prefix = INCLUDE_TOKENS.detect { |t| File.basename(file).match?(t) } if PREFER_NOT_PATH

      seconds = Benchmark.realtime do
        ret = if RequireBench::TIMEOUT.zero?
                Kernel.send("#{type}_without_timing", file, *args)
              else
                # Raise Timeout::Error if more than RequireBench::TIMEOUT seconds are spent in the block
                # This is a giant hammer, and should probably only be used to figure out where an infinite loop might be hiding.
                Timeout.timeout(RequireBench::TIMEOUT) do
                  Kernel.send("#{type}_without_timing", file, *args)
                end
              end
      end
      PRINTER.out_consume(seconds, file, short_type)
      if prefix.nil? && (NO_GROUP_PATTERN.nil? || !NO_GROUP_PATTERN.match?(file))
        # This results in grouping all files with the same leading path part (e.g. "models", or "lib")
        #   into the same timing bucket.
        # requires that were fully qualified paths probably need to be identified
        #   by the full path
        prefix = if (match = INCLUDE_PATTERN&.match(file))
                   match[0]
                 else
                   # Generally this will target a library name, e.g. "rspec"
                   #    which sums all require timings from a single library together
                   file.partition('/').first
                 end
      end
      prefix = file if prefix.nil? || prefix.empty?
      RequireBench::TIMINGS[prefix] += seconds
      ret
    ensure
      $require_bench_semaphore = nil
    end
    module_function :consume_with_timing
  end
end

if REQUIRE_BENCH_ENABLED
  # A Kernel hack that adds require timing to find require problems in app.
  module Kernel
    alias require_without_timing require
    alias load_without_timing load

    def require(file)
      _require_bench_consume_file('require', file)
    end

    def load(file,  *args)
      _require_bench_consume_file('load', file, *args)
    end

    def _require_bench_consume_file(type, file, *args)
      file_path = file.to_s
      # byebug if file_path.match?(/no_group_fox/)

      # Global $ variable, which is always truthy while inside the hack, is to
      #   prevent a scenario that might result in infinite recursion.
      return send("#{type}_without_timing", file_path, *args) if $require_bench_semaphore

      short_type = type[0]
      measure = RequireBench::INCLUDE_PATTERN && file_path.match?(RequireBench::INCLUDE_PATTERN)
      skippy = RequireBench::SKIP_PATTERN && file_path.match?(RequireBench::SKIP_PATTERN)
      RequireBench::PRINTER.out_start(file, short_type) if RequireBench::LOG_START
      if RequireBench::RESCUED_CLASSES.any?
        begin
          _require_bench_file(type, measure, skippy, file_path, *args)
        rescue *RequireBench::RESCUED_CLASSES => e
          RequireBench::PRINTER.out_error(e, file, short_type, *args)
        end
      else
        _require_bench_file(type, measure, skippy, file_path, *args)
      end
    end

    def _require_bench_file(type, measure, skippy, file_path, *args)
      if !measure && skippy
        send("#{type}_without_timing", file_path, *args)
      elsif RequireBench::INCLUDE_PATTERN.nil? || measure
        RequireBench.consume_with_timing(type, file_path, *args)
      else
        send("#{type}_without_timing", file_path, *args)
      end
    end
  end
end

RequireBench::Version.class_eval do
  extend VersionGem::Basic
end
