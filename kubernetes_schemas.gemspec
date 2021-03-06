
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kubernetes_schemas/version"

Gem::Specification.new do |spec|
  spec.name          = "kubernetes_schemas"
  spec.version       = KubernetesSchemas::VERSION
  spec.authors       = ["Pavel Forkert"]
  spec.email         = ["fxposter@gmail.com"]

  spec.summary       = %q{Validate your kubernetes resources against specific version of kubernetes api}
  spec.description   = %q{Validate your kubernetes resources against specific version of kubernetes api}
  spec.homepage      = "https://github.com/fxposter/kubernetes_schemas"


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json_schemer"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
