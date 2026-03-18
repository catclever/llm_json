# LLMJSON

**LLMJSON** is a pure Ruby library designed for intelligent extraction and repair of broken or unformatted JSON commonly output by Large Language Models (LLMs). Through intelligent bracket matching, markdown parsing, and regex fallback strategies, it serves as a seamless drop-in replacement for Ruby's standard `JSON` library.

[中文文档 (Chinese Documentation)](./README.zh-CN.md)

## Features

- **Drop-in Replacement**: Fully compatible with standard `JSON.parse` and `JSON.generate/dump`.
- **Markdown Extraction**: Automatically scans and strips away conversational text (like `Here is the JSON you requested: ...`) and pulls code from ````json ... ```` fences.
- **Intelligent Bracket Matching**: Dynamically counts `{ }` and `[ ]` brackets while ignoring escaped characters in strings to locate JSON blocks safely within messy outputs.
- **Auto Error Recovery**: Fixes common structural errors made by LLMs, including:
  - Removing trailing commas (`{"a": 1,}`)
  - Converting single-quoted keys and values to valid double quotes (`{'key': 'value'}`)
  - Auto-quoting naked keys (`{key: "value"}`)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'llm_json'
```

And then execute:
```bash
$ bundle install
```

## Usage

### 1. Alternative to `JSON.parse` / `JSON.load`
Pass any broken, Markdown-wrapped, or malformed LLM response. LLMJSON will attempt to fix it and return the Ruby Hash/Array.

```ruby
require 'llm_json'

# Malformed JSON (Missing quotes on keys, single quotes, trailing commas)
broken_llm_output = <<~MD
  Sure! Here is the response you asked for:
  ```json
  {
    response_code: 200,
    'message': 'success',
  }
  ```
MD

data = LLMJSON.parse(broken_llm_output)
# => {"response_code"=>200, "message"=>"success"}
```

### 2. Alternative to `JSON.generate` / `JSON.dump`
Use `LLMJSON.dump` when you need to serialize a Ruby Object, or when you proactively want to heal a broken JSON string and output a **valid JSON string**.

```ruby
# If you pass a Ruby Hash, it works exactly like JSON.generate
LLMJSON.dump({ hello: "world" })
# => '{"hello":"world"}'

# If you pass a broken JSON String, it parses, heals, and returns a valid String
LLMJSON.dump("{ 'broken': true, }")
# => '{"broken":true}'
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rspec` to run the tests.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
