# frozen_string_literal: true

require_relative "lib/kukushka/version"

Gem::Specification.new do |spec|
  spec.name = "kukushka"
  spec.version = Kukushka::VERSION
  spec.authors = ["Serge Kislak"]
  spec.email = ["kislak7@gmail.com"]

  spec.summary = "interval repetition"
  spec.description = "Learning tool for interval repetition"
  spec.homepage = "https://github/kislak/kukushka"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rainbow", '~> 3.0'
  spec.add_dependency "commander", '~> 4.4'
  spec.add_dependency "redis", '~> 5.3'
  spec.add_dependency "redis-namespace", '~> 1.11'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
