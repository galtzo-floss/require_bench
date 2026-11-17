# frozen_string_literal: true

# std libs
require "forwardable"

# internal colorizer (replaces the GPL-2.0-licensed colorize gem)
require "require_bench/colors"

# Default Printer, unless NO_COLOR is set (see lib/require_bench.rb).

class Printer
  attr_accessor :colors, :color

  extend Forwardable

  def_delegators :@colors, :rotate!, :first
  def initialize
    @colors = RequireBench::Colors::NAMES.dup
  end

  # Log statement when a file starts loading
  def out_start(file, type)
    printf("🚥 #{RequireBench::Colors.colorize("[RequireBench-#{type}]", first)} 📖 %s 🚥\n", file)
  end

  # Log statement when a file completed loading
  def out_consume(seconds, file, type)
    printf("🚥 #{RequireBench::Colors.colorize("[RequireBench-#{type}]", first)} ☑️ %10f %s 🚥\n", seconds, file)
    rotate!
  end

  # Log statement when a file raises an error while loading
  def out_err(error, file, type)
    printf(
      "🚥 #{RequireBench::Colors.colorize("[RequireBench-#{type}]", first)} ❌ '#{error.class}: #{error.message}' loading %s 🚥\n#{error.backtrace.join("\n")}",
      file
    )
    rotate!
  end
end
