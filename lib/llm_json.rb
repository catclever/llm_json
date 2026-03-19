# frozen_string_literal: true

require_relative "llm_json/json_core"

module LLMJSON
  class Error < StandardError; end

  class << self
    # Drop-in replacement for JSON.parse
    # Returns the parsed Ruby object (Hash/Array), or raises JSON::ParserError if it completely fails.
    def parse(text, opts = {})
      result = JSONCore.new.parse(text)
      if result.success?
        result.data
      else
        raise JSON::ParserError, result.error
      end
    end

    alias load parse

    # Drop-in replacement for JSON.generate / JSON.dump
    # If given a String, it assumes it's broken AI JSON, fixes it, and returns a valid JSON string.
    # If given a Ruby object, it acts like a normal JSON.generate.
    def generate(obj, *args)
      if obj.is_a?(String)
        parsed = parse(obj)
        JSON.generate(parsed, *args)
      else
        JSON.generate(obj, *args)
      end
    end

    alias dump generate
  end
end
