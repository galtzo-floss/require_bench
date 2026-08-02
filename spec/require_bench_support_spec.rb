# frozen_string_literal: true

RSpec.describe RequireBench do
  describe Printer do
    subject(:printer) { described_class.new }

    it "prints start, completion, and error messages" do
      error = RuntimeError.new("boom")
      error.set_backtrace(["example.rb:1"])

      output = capture(:stdout) do
        printer.out_start("support/example", "r")
        printer.out_consume(0.125, "support/example", "r")
        printer.out_err(error, "support/example", "r")
      end

      expect(output).to include("[RequireBench-r]")
      expect(output).to include("support/example")
      expect(output).to include("RuntimeError: boom")
      expect(output).to include("example.rb:1")
    end
  end

  describe "the color printer" do
    subject(:printer) do
      ObjectSpace.each_object(Class).find do |klass|
        next unless klass.method_defined?(:out_start)

        location = klass.instance_method(:out_start).source_location
        location && location.first.end_with?("lib/require_bench/color_printer.rb")
      end.new
    end

    before do
      require "colorized_string"
      load File.expand_path("../lib/require_bench/color_printer.rb", __dir__), true
    end

    it "prints colored messages and rotates colors" do
      error = RuntimeError.new("boom")
      error.set_backtrace(["example.rb:1"])

      output = capture(:stdout) do
        printer.out_start("support/example", "r")
        printer.out_consume(0.125, "support/example", "r")
        printer.out_err(error, "support/example", "r")
      end

      expect(output).to include("[RequireBench-r]")
      expect(output).to include("support/example")
      expect(output).to include("RuntimeError: boom")
    end
  end

  describe "require_bench:hello" do
    before do
      require "rake"
      Rake::Task.define_task(:environment)
      load File.expand_path("../lib/require_bench/tasks.rb", __dir__)
      Rake::Task["require_bench:hello"].reenable
      Rake::Task["environment"].reenable
    end

    it "reports tracked timings in descending order" do
      described_class::TIMINGS.clear
      described_class::TIMINGS["slow"] = 0.2
      described_class::TIMINGS["fast"] = 0.1

      output = capture(:stdout) { Rake::Task["require_bench:hello"].invoke }

      expect(output).to include("Slowest Loads by Library, in order")
      expect(output.index("slow")).to be < output.index("fast")
      expect(output).to include("TOTAL")
    end

    it "explains why no timings were recorded" do
      described_class::TIMINGS.clear

      output = capture(:stdout) { Rake::Task["require_bench:hello"].invoke }

      expect(output).to include("did not track any requires")
      expect(output).to include("require_bench:hello")
    end
  end
end
