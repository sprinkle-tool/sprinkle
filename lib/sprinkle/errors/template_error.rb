module Sprinkle::Errors
  # Blatantly stole this from Chef
  class TemplateError < RuntimeError #:nodoc:
    attr_reader :original_exception, :context
    SOURCE_CONTEXT_WINDOW = 2 unless defined? SOURCE_CONTEXT_WINDOW

    def initialize(original_exception, template, context)
      @original_exception, @template, @context = original_exception, template, context
    end

    def message
      @original_exception.message
    end

    def line_number
      @line_number ||= $1.to_i if original_exception.backtrace.find {|line| line =~ /\(erubis\):(\d+)/ }
    end

    def source_location
      "on line ##{line_number}"
    end

    def source_listing
      return nil if line_number.nil?

      @source_listing ||= begin
        line_index = line_number - 1
        beginning_line = line_index <= SOURCE_CONTEXT_WINDOW ? 0 : line_index - SOURCE_CONTEXT_WINDOW
        source_size = SOURCE_CONTEXT_WINDOW * 2 + 1
        lines = @template.split(/\n/)
        contextual_lines = lines[beginning_line, source_size]
        output = []
        contextual_lines.each_with_index do |line, index|
          line_number = (index+beginning_line+1).to_s.rjust(3)
          output << "#{line_number}: #{line}"
        end
        output.join("\n")
      end
    end

    def to_s
      "\n\n#{self.class} (#{message}) #{source_location}:\n\n" +
        "#{source_listing}\n\n  #{original_exception.backtrace.join("\n  ")}\n\n"
    end
  end
end