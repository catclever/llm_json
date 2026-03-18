# frozen_string_literal: true

require "spec_helper"

RSpec.describe LLMJSON do
  describe ".parse" do
    it "returns the Ruby object directly" do
      input = '{"a": 1}'
      expect(LLMJSON.parse(input)).to eq("a" => 1)
    end

    it "fixes broken JSON and returns the Ruby object" do
      input = "{ 'a': 1, }"
      expect(LLMJSON.parse(input)).to eq("a" => 1)
    end

    it "raises JSON::ParserError on complete failure" do
      expect {
        LLMJSON.parse("this is strictly text")
      }.to raise_error(JSON::ParserError)
    end
  end

  describe ".dump" do
    it "serializes a standard Ruby object into a JSON string" do
      hash = { "a" => 1 }
      expect(LLMJSON.dump(hash)).to eq('{"a":1}')
    end

    it "takes a broken JSON string, fixes it, and returns a valid JSON string" do
      input = <<~MD
        ```json
        { 'a': 1, }
        ```
      MD
      # Note: Output depends on JSON.generate formatting, usually compact without spaces
      expect(LLMJSON.dump(input)).to eq('{"a":1}')
    end
  end
end
