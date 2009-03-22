Gem::Specification.new do |s|
  s.name     = "nickel"
  s.version  = "0.0.1"
  s.date     = "2009-03-22"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.summary  = "Natural language date and time parsing"
  s.email    = "lzell11@gmail.com"
  s.homepage = "naturalinputs.com"
	s.description = "A client for naturalinputs.com.  Extracts date, time, and message information from naturally worded text."
  s.has_rdoc = true
  s.authors  = ["Lou Zell"]
  s.files    = ["README.rdoc", 
      "History.txt",
      "License.txt",
      "nickel.gemspec",
      "test/nickel_spec.rb",
      "lib/nickel.rb"]
  s.require_paths = ["lib"]
  s.rdoc_options = ["--main", "README.rdoc", "--title", "Nickel"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.add_dependency("lzell-mapricot")
end
