# frozen_string_literal: true

require "spec_helper"

RSpec.describe LLMJSON::JSONCore do
  subject(:parser) { described_class.new }

  describe "#parse" do
    it "parses valid JSON directly" do
      input = '{"key": "value"}'
      result = parser.parse(input)
      expect(result).to be_success
      expect(result.data).to eq("key" => "value")
    end

    it "extracts JSON from markdown code block" do
      input = <<~MD
        Here is the JSON you requested:
        ```json
        {
          "message": "hello world"
        }
        ```
      MD
      result = parser.parse(input)
      expect(result).to be_success
      expect(result.data).to eq("message" => "hello world")
    end

    it "extracts JSON block intelligently from messy text" do
      input = <<~TEXT
        Sure, here is your output:
        {
          "user_id": 123,
          "username": "test"
        }
        Hope this helps!
      TEXT
      result = parser.parse(input)
      expect(result).to be_success
      expect(result.data).to eq("user_id" => 123, "username" => "test")
    end

    it "fixes trailing commas and parses" do
      input = <<~JSON
        {
          "list": [1, 2, 3,],
          "obj": {"a": 1,}
        }
      JSON
      result = parser.parse(input)
      expect(result).to be_success
      expect(result.data).to eq("list" => [1, 2, 3], "obj" => { "a" => 1 })
    end

    it "fixes single quotes in keys and values" do
      input = <<~JSON
        {
          'status': 'success',
          'code': 200
        }
      JSON
      result = parser.parse(input)
      expect(result).to be_success
      expect(result.data).to eq("status" => "success", "code" => 200)
    end

    it "fixes unquoted keys" do
      input = <<~JSON
        {
          username: "foo",
          age: 20
        }
      JSON
      result = parser.parse(input)
      expect(result).to be_success
      expect(result.data).to eq("username" => "foo", "age" => 20)
    end

    it "returns failure when nothing works" do
      input = "This is just text with no JSON whatsoever"
      result = parser.parse(input)
      expect(result).not_to be_success
      expect(result.error).not_to be_nil
    end
  end
end
