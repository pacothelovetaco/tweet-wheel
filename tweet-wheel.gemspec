# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tweet-wheel/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Leavitt"]
  gem.email         = ["pacothelovetaco@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tweet-wheel"
  gem.require_paths = ["lib"]
  gem.version       = Tweet::Wheel::VERSION
end
