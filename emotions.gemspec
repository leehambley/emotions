# -*- encoding: utf-8 -*-
require File.expand_path('../lib/emotions/version', __FILE__)

Gem::Specification.new do |gem|

  gem.authors       = ["Lee Hambley"]
  gem.email         = ["lee.hambley@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "emotions"
  gem.require_paths = ["lib"]
  gem.version       = Emotions::VERSION

  gem.add_dependency('redis')

  gem.add_development_dependency('minitest')
  gem.add_development_dependency('turn')
  gem.add_development_dependency('daemon_controller')

end
