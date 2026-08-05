# frozen_string_literal: true

RSpec.describe RequireBench do
  let(:std_library) { "ostruct" }
  let(:skipped_library_by_name) { ["SkippedBird", nil, "1", false] }
  let(:skipped_library_by_dir) { ["SkippedBird", "skipped/", "2", false] }
  let(:skipped_nested_library_by_name) { ["SkippedNestedBird", "nested/disparate/", "3", false] }
  let(:skipped_nested_library_by_dir) { ["SkippedNestedDog", "nested/ignored/", "4", false] }
  let(:included_library_by_name) { ["LoggedTiger", nil, "5", nil] }
  let(:included_library_by_dir) { ["LoggedEagle", "grouped/", "6", "grouped"] }
  let(:included_nested_library_by_name) { ["LoggedDuck", "nested/disparate/", "7", nil] }
  let(:included_nested_library_by_dir) { ["LoggedNestedTiger", "nested/collected/", "8", "nested/collected"] }
  let(:included_skipped_library_by_name) { ["LoggedSkippedLion", "skipped/", "9", nil] }
  let(:no_group_library_by_name) { ["NoGroupFish", "grouped/", "10", "support/my_library/grouped/no_group_fish"] }
  let(:no_group_library_by_dir) { ["NoGroupFox", "separate/", "11", nil] }
  let(:no_group_nested_library_by_name) do
    ["NoGroupFly", "nested/collected/", "12", "support/my_library/nested/collected/no_group_fly"]
  end
  let(:no_group_nested_library_by_dir) { ["NoGroupCat", "nested/disparate/", "13", nil] }
  let(:my_nested_module) { library[0] }
  let(:my_module) { LuckyCase.constantize("MyLibrary::#{my_nested_module}") }
  let(:my_version) { my_module::VERSION }
  let(:my_patch) { library[2] }
  let(:timings_key) do
    key = library[3]
    # when nil then file_name, when false no key, otherwise string
    if key.nil?
      file_name
    elsif !key
      nil
    else
      key
    end
  end
  let(:library_version) { "0.0.#{my_patch}" }
  let(:file_name) { LuckyCase.snake_case(my_nested_module) }
  let(:file_dir) { library[1] }
  let(:file_path) { "#{file_dir}#{file_name}" }
  let(:require_path) { "support/my_library/#{file_path}" }
  let(:req) { require(require_path) }
  let(:quiet_req) { quietly { require(require_path) } }
  let(:log_match) { /🚥\s\[RequireBench-r\]\s☑️\s+\d\.\d+ #{Regexp.escape(require_path)}\s🚥\n/i }

  before do
    create_lib_file(file_name, file_dir, my_patch)
  end

  after do
    delete_lib_file(file_name, file_dir)
  end

  context "when skipped" do
    shared_examples_for "skipped" do
      it "does not break require" do
        quiet_req
        expect(my_version).to eq(library_version)
      end

      it "does not log require" do
        output = capture(:stdout) { req }
        expect(output).not_to match(log_match)
      end

      it "does track timings of other libraries" do
        quietly { require std_library }
        expect(RequireBench::TIMINGS).to have_key(std_library)
      end

      it "tracks timing of other libraries as a Float" do
        quietly { require std_library }
        expect(RequireBench::TIMINGS[std_library]).to be_a(Float)
      end

      it "does not track timings of skipped library" do
        quiet_req
        expect(RequireBench::TIMINGS).not_to have_key(file_name)
        expect(RequireBench::TIMINGS).not_to have_key(file_path)
      end

      it "has only string TIMINGS keys" do
        quietly { require std_library }
        expect(RequireBench::TIMINGS.keys.reject { |x| x.is_a?(String) }).to be_empty
      end
    end

    context "when by name" do
      it_behaves_like "skipped" do
        let(:library) { skipped_library_by_name }
      end
    end

    context "when by dir" do
      it_behaves_like "skipped" do
        let(:library) { skipped_library_by_dir }
      end
    end

    context "when nested" do
      context "when by name" do
        it_behaves_like "skipped" do
          let(:library) { skipped_nested_library_by_name }
        end
      end

      context "when by dir" do
        it_behaves_like "skipped" do
          let(:library) { skipped_nested_library_by_dir }
        end
      end
    end
  end

  context "when included" do
    shared_examples_for "logged" do
      it "does not break require" do
        quiet_req
        expect(my_version).to eq(library_version)
      end

      it "does log require" do
        output = capture(:stdout) { req }
        expect(output).to match(log_match)
      end

      it "does track timings" do
        quiet_req
        expect(RequireBench::TIMINGS).to have_key(timings_key)
      end

      it "tracks timing as a Float" do
        quiet_req
        expect(RequireBench::TIMINGS[timings_key]).to be_a(Float)
      end

      it "has only string TIMINGS keys" do
        quiet_req
        expect(RequireBench::TIMINGS.keys.reject { |x| x.is_a?(String) }).to be_empty
      end
    end

    context "when by name" do
      it_behaves_like "logged" do
        let(:library) { included_library_by_name }
      end
    end

    context "when by dir" do
      it_behaves_like "logged" do
        let(:library) { included_library_by_dir }
      end
    end

    context "when nested" do
      context "when by name" do
        it_behaves_like "logged" do
          let(:library) { included_nested_library_by_name }
        end
      end

      context "when by dir" do
        it_behaves_like "logged" do
          let(:library) { included_nested_library_by_dir }
        end
      end
    end

    context "when skipped overridden" do
      context "when by name" do
        it_behaves_like "logged" do
          let(:library) { included_skipped_library_by_name }
        end
      end
    end

    context "when not grouped" do
      context "when by name" do
        it_behaves_like "logged" do
          let(:library) { no_group_library_by_name }
        end
      end

      context "when by dir" do
        it_behaves_like "logged" do
          let(:library) { no_group_library_by_dir }
        end
      end

      context "when nested" do
        context "when by name" do
          it_behaves_like "logged" do
            let(:library) { no_group_nested_library_by_name }
          end
        end

        context "when by dir" do
          it_behaves_like "logged" do
            let(:library) { no_group_nested_library_by_dir }
          end
        end
      end
    end
  end

  describe "the require hook branches" do
    let(:library) { included_library_by_name }

    let(:runner) do
      Object.new.tap do |object|
        object.extend(Kernel)
        object.define_singleton_method(:require_without_timing) do |file, *args|
          [:direct, file, args]
        end
      end
    end

    it "does not interfere with lazy RSpec matcher loading" do
      expect(RSpec::Matchers::BuiltIn::Eq.new(:expected)).to be_a(RSpec::Matchers::BuiltIn::BaseMatcher)
    end

    it "keeps the recursion guard local to its thread" do
      ready = Queue.new
      release = Queue.new

      begin
        # rubocop:disable ThreadSafety/NewThread
        worker = Thread.new do
          Thread.current[RequireBench::SEMAPHORE_KEY] = true
          ready << true
          release.pop
        end
        # rubocop:enable ThreadSafety/NewThread

        ready.pop
        expect(described_class.semaphore_active?).to be(false)
      ensure
        release << true
        worker.join if worker
      end
    end

    it "bypasses timing for skipped files" do
      result = runner.send(:_require_bench_file, "require", false, true, "skipped_file")

      expect(result).to eq([:direct, "skipped_file", []])
    end

    it "measures explicitly included files" do
      allow(described_class).to receive(:consume_with_timing).and_return(:measured)

      result = runner.send(:_require_bench_file, "require", true, false, "included_file")

      expect(result).to eq(:measured)
    end

    it "measures all files when no include pattern is configured" do
      stub_const("RequireBench::INCLUDE_PATTERN", nil)
      allow(described_class).to receive(:consume_with_timing).and_return(:measured)

      result = runner.send(:_require_bench_file, "require", false, false, "unfiltered_file")

      expect(result).to eq(:measured)
    end

    it "handles rescued load errors through the printer" do
      stub_const("RequireBench::RESCUED_CLASSES", [LoadError])
      missing_file = "missing_require_bench_file"
      runner.define_singleton_method(:require_without_timing) do |file, *args|
        raise LoadError, "cannot load such file -- #{file}"
      end

      expect do
        runner.send(:_require_bench_consume_file, "require", missing_file)
      end.to output(/LoadError/).to_stdout
    end

    it "uses the timeout path when configured" do
      path = File.expand_path("support/my_library/timeout_file.rb", __dir__)
      File.write(path, "TimeoutFile = true\n")
      stub_const("RequireBench::TIMEOUT", 1)

      begin
        described_class.consume_with_timing("require", path)
      ensure
        $LOADED_FEATURES.delete(path)
        File.delete(path) if File.exist?(path)
      end

      expect(described_class::TIMINGS).to have_key(path)
    end
  end
end
