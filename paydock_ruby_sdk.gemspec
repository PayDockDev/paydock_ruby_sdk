$LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), "lib"))

Gem::Specification.new do |s|
  s.name = "paydock_ruby_sdk"
  s.version = "0.1"
  s.required_ruby_version = ">= 2.6.5"
  s.summary = "Ruby bindings for the PayDock API"
  s.description = "This SDK provides a wrapper around the PayDock REST API. This is currently a work in progress, stay tuned for updates"
  s.author = "PayDock"
  s.email = "support@paydock.com"
  s.homepage = "https://paydock.com/"

  s.metadata = {
    "github_repo" => "https://github.com/PayDock/paydock_ruby_sdk.git",
    "source_code_uri" => "https://github.com/PayDock/paydock_ruby_sdk.git",
  }

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| ::File.basename(f) }
  s.require_paths = ["lib"]
end
