# frozen_string_literal: true

class Printer
  # Log statement when a file starts loading
  def out_start(file, type)
    printf("🚥 [RequireBench-#{type}] 📖 %s 🚥\n", file)
  end

  # Log statement when a file completed loading
  def out_consume(seconds, file, type)
    printf("🚥 [RequireBench-#{type}] ☑️ %10f %s 🚥\n", seconds, file)
  end

  # Log statement when a file raises an error while loading
  def out_err(error, file, type)
    printf(
      "🚥 [RequireBench-#{type}] ❌ '#{error.class}: #{error.message}' loading %s 🚥\n#{error.backtrace.join("\n")}",
      file
    )
  end
end
