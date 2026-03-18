# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "llm_json"
  spec.version       = "0.1.0"
  spec.authors       = ["Kael"]
  spec.email         = ["kael@example.com"]

  spec.summary       = "A pure JSON parser with intelligent fallback and fixing strategies for AI LLM outputs."
  spec.description   = "Ports robust JSON extraction and format fixing from Python to Ruby."
  spec.homepage      = "https://example.com/llm_json"
  spec.license       = "MIT"

  spec.require_paths = ["lib"]

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.add_development_dependency "rspec", "~> 3.12"
end
