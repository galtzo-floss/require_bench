# frozen_string_literal: true

module RequireBench
  # Minimal internal ANSI colorizer for the color printer.
  #
  # Replaces the GPL-2.0-licensed colorize gem, which was previously the only
  # way to enable colored output. The color printer is the default; see
  # lib/require_bench.rb (set NO_COLOR for the plain printer).
  module Colors
    # ANSI SGR color codes. Black and white are intentionally omitted:
    # they are illegible on common terminal themes.
    CODES = {
      red: 31,
      green: 32,
      yellow: 33,
      blue: 34,
      magenta: 35,
      cyan: 36,
      light_red: 91,
      light_green: 92,
      light_yellow: 93,
      light_blue: 94,
      light_magenta: 95,
      light_cyan: 96,
    }.freeze

    # Ordered color names the color printer rotates through.
    NAMES = CODES.keys.freeze

    # Wrap a string in the ANSI escape sequence for the named color.
    #
    # @param string [String] the text to colorize
    # @param name [Symbol] one of {NAMES}
    # @return [String] the colorized text
    # @raise [KeyError] when the color name is unknown
    def self.colorize(string, name)
      "\e[#{CODES.fetch(name)}m#{string}\e[0m"
    end
  end
end
