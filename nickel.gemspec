Gem::Specification.new do |s|
  s.name     = "nickel"
  s.version  = "0.0.6"
  s.summary  = "Natural language date, time, and message parsing."
  s.email    = "lzell11@gmail.com"
  s.homepage = "http://github.com/lzell/nickel"
	s.description = "Extracts date, time, and message information from naturally worded text."
  s.has_rdoc = true
  s.authors  = ["Lou Zell"]
  s.files    = 
    [
        "History.txt",
        "License.txt",
        "README.rdoc", 
        "Rakefile",
        "nickel.gemspec",
        "lib/nickel.rb",
        "lib/nickel/construct.rb",
        "lib/nickel/construct_finder.rb",
        "lib/nickel/construct_interpreter.rb",
        "lib/nickel/instance_from_hash.rb",
        "lib/nickel/nlp.rb",
        "lib/nickel/occurrence.rb",
        "lib/nickel/query.rb",
        "lib/nickel/query_constants.rb",
        "lib/nickel/zdate.rb",
        "lib/nickel/ztime.rb",
        "lib/nickel/ruby_ext/calling_method.rb",
        "lib/nickel/ruby_ext/to_s2.rb",
        "test/compare.rb",
        "test/nlp_test.rb",
        "test/nlp_tests_helper.rb",
        "test/zdate_test.rb",
        "test/ztime_test.rb",
        "spec/nickel_spec.rb"
    ]
  s.require_paths = ["lib"]
  s.rdoc_options = ["--main", "README.rdoc", "--title", "Nickel"]
  s.extra_rdoc_files = ["README.rdoc"]
end
