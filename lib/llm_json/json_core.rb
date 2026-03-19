# frozen_string_literal: true

require 'json'

module LLMJSON
  class ParseResult
    attr_reader :success, :data, :error, :raw_input

    def initialize(success:, data: nil, error: nil, raw_input: "")
      @success = success
      @data = data
      @error = error
      @raw_input = raw_input
    end

    def success?
      @success
    end
  end

  class JSONCore
    def parse(raw_input)
      return ParseResult.new(success: false, error: "Input is empty", raw_input: raw_input) if raw_input.nil? || raw_input.strip.empty?

      # Strategy 1: Direct Parse
      result = try_direct_parse(raw_input)
      return result if result.success?

      # Strategy 2: Extract from Markdown
      result = try_markdown_extraction(raw_input)
      return result if result.success?

      # Strategy 3: Intelligent Block Extraction
      result = try_block_extraction(raw_input)
      return result if result.success?

      # Strategy 4: Error Fixing
      result = try_error_fixing(raw_input)
      return result if result.success?

      ParseResult.new(success: false, error: "All parsing strategies failed", raw_input: raw_input)
    end

    private

    def try_direct_parse(text)
      data = JSON.parse(text.strip)
      ParseResult.new(success: true, data: data, raw_input: text)
    rescue JSON::ParserError => e
      ParseResult.new(success: false, error: "Direct parse failed: #{e.message}", raw_input: text)
    end

    def try_markdown_extraction(text)
      json_blocks = extract_from_markdown(text)
      
      json_blocks.each do |block|
        begin
          data = JSON.parse(block.strip)
          return ParseResult.new(success: true, data: data, raw_input: text)
        rescue JSON::ParserError
        end

        fixed_block = fix_common_json_errors(block.strip)
        begin
          data = JSON.parse(fixed_block)
          return ParseResult.new(success: true, data: data, raw_input: text)
        rescue JSON::ParserError
          next
        end
      end

      ParseResult.new(success: false, error: "Markdown extraction failed", raw_input: text)
    end

    def try_block_extraction(text)
      json_blocks = extract_json_blocks(text)
      
      json_blocks.each do |block|
        begin
          data = JSON.parse(block)
          return ParseResult.new(success: true, data: data, raw_input: text)
        rescue JSON::ParserError
        end

        fixed_block = fix_common_json_errors(block)
        begin
          data = JSON.parse(fixed_block)
          return ParseResult.new(success: true, data: data, raw_input: text)
        rescue JSON::ParserError
          next
        end
      end

      ParseResult.new(success: false, error: "Block extraction failed", raw_input: text)
    end

    def try_error_fixing(text)
      fixed_text = fix_common_json_errors(text)
      
      begin
        data = JSON.parse(fixed_text)
        ParseResult.new(success: true, data: data, raw_input: text)
      rescue JSON::ParserError => e
        ParseResult.new(success: false, error: "Failed even after error fixing: #{e.message}", raw_input: text)
      end
    end

    # Extraction Strategies

    def extract_from_markdown(text)
      blocks = []
      
      # ```json ... ```
      text.scan(/```json\s*(.*?)\s*```/m) { |match| blocks << match[0] }
      
      # ``` ... ``` (where the inside looks like {} or [])
      text.scan(/```\s*([\{\[].*?[\}\]])\s*```/m) { |match| blocks << match[0] }
      
      blocks
    end

    def extract_json_blocks(text)
      blocks = []
      
      ['{', '['].each_with_index do |start_char, index|
        end_char = index == 0 ? '}' : ']'
        start_pos = 0

        while (start_idx = text.index(start_char, start_pos))
          bracket_count = 0
          end_idx = start_idx
          in_string = false
          escape_next = false

          (start_idx...text.length).each do |i|
            char = text[i]

            if escape_next
              escape_next = false
              next
            end

            if char == '\\'
              escape_next = true
              next
            end

            if char == '"' && !escape_next
              in_string = !in_string
              next
            end

            unless in_string
              if char == start_char
                bracket_count += 1
              elsif char == end_char
                bracket_count -= 1
              end

              if bracket_count == 0
                end_idx = i
                break
              end
            end
          end

          if bracket_count == 0
            candidate = text[start_idx..end_idx]
            blocks << candidate
          end

          start_pos = start_idx + 1
        end
      end

      blocks
    end

    def fix_common_json_errors(text)
      fixed = text.dup
      
      # Remove trailing commas: ,} or ,]
      fixed.gsub!(/,(\s*[}\]])/, '\1')
      
      # Fix single quotes in keys: 'key': -> "key":
      fixed.gsub!(/'([^']*)':/, '"\1":')
      
      # Fix single quotes in values: : 'value' -> : "value"
      fixed.gsub!(/:\s*'([^']*)'/, ': "\1"')
      
      # Fix unquoted keys: { key: "value" } -> { "key": "value" }
      fixed.gsub!(/([{,]\s*)([a-zA-Z_][a-zA-Z0-9_]*)\s*:/, '\1"\2":')
      
      fixed.strip
    end
  end
end
