# frozen_string_literal: true

require "anonymous_loader"
require "require_bench"
RSpec.describe RequireBench::Version do
  it_behaves_like "a Version module", described_class

  it "is greater than 0.1.0" do
    expect(Gem::Version.new(described_class) > Gem::Version.new("0.1.0")).to be(true)
  end

  it "is greater than 1.0.0" do
    expect(Gem::Version.new(described_class) >= Gem::Version.new("1.0.0")).to be(true)
  end

  it "executes the version file for coverage without redefining constants" do
    dir = File.expand_path("../../lib/require_bench", __dir__)
    paths = %w[version.rb version_gem.rb].map { |file| File.join(dir, file) }.select { |path| File.file?(path) }
    anonymous_namespace = AnonymousLoader.load(files: paths)

    expect(anonymous_namespace::RequireBench::Version::VERSION).to eq(described_class::VERSION)
  end
end
