# LLMJSON

**LLMJSON** 是一个专门针对大语言模型 (LLM) 输出的破损或非标准 JSON 格式进行智能提取与修复的纯 Ruby 库。基于智能括号匹配、Markdown 清洗和正则表达式后备容错策略，它可以作为 Ruby 标准 `JSON` 库的直接无缝替换 (Drop-in Replacement)。

[English Documentation](./README.md)

## 核心特性

- **完全无缝替换 (Drop-in Replacement)**: 高度兼容标准的 `JSON.parse` 和 `JSON.generate/dump` 的调用方式。
- **Markdown 智能提取**: 自动忽略 LLM 输出前后的无关废话（如“好的，为你生成如下 JSON：”），并精准提取 ````json ... ```` 代码块内部的内容。
- **括号智能匹配 (Bracket Matching)**: 能够动态计数 `{ }` 与 `[ ]`，同时忽略字符串内部的转义闭合符，安全地在污染的文本中抽取真实 JSON 数据块。
- **自动格式容错系统**: 自动修复大模型极易犯的几种低级语法错：
  - 去除数组或对象末尾经常多出来的尾随逗号 (`{"a": 1,}`)
  - 修正被错误写成单引号的 Key 和 Value (`{'key': 'value'}`)
  - 为没有包裹引号的纯裸 Key 自动补全引号 (`{key: "value"}`)

## 安装

将这行代码加入你的应用 `Gemfile` 中:

```ruby
gem 'llm_json'
```

然后执行打包命令:
```bash
$ bundle install
```

## 使用方法

### 1. 替代 `JSON.parse` / `JSON.load`
把遭到破坏的、被 Markdown 包裹的或者格式混乱的大模型输出喂给它，LLMJSON 将自动尝试修复并直接返回 Ruby `Hash` 散列或 `Array` 数组。

```ruby
require 'llm_json'

# 一个格式非常恶劣的 LLM 输出：没加引号的 key、单引号的 value、尾随多余的逗号
broken_llm_output = <<~MD
  没问题，这是你需要的数据结构：
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

### 2. 替代 `JSON.generate` / `JSON.dump`
通常你会直接传入 Ruby 对象来执行标准的 `generate`，但 `LLMJSON.dump` 额外提供了一个魔法能力：如果你传入的是一个**字符串**，它会先将这个已损坏的字符串修复，并且吐出**严格标准且合法的 JSON 字符串**。

```ruby
# 当传入普通 Ruby 对象时，行为同 JSON.generate
LLMJSON.dump({ hello: "world" })
# => '{"hello":"world"}'

# 当你想要直接修复一段脏字符串，最终把它交给其他严格要求 JSON 格式的 HTTP 服务时
LLMJSON.dump("{ 'broken': true, }")
# => '{"broken":true}'
```

## 本地开发指南

拉取代码后，执行 `bundle install` 安装测试所需的依赖。接着，使用 `bundle exec rspec` 即可运行全部测试用例。

## 开源协议

LLMJSON 采用 [MIT License](https://opensource.org/licenses/MIT) 协议进行开源发布。
