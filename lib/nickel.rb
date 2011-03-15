# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]
#
# Usage:
# 
#   Nickel.parse "some query", Time.local(2011, 7, 1)
#
# The second term is optional.

require 'logger'
require 'date'

path = File.expand_path(File.join(File.dirname(__FILE__), 'nickel'))

require File.join(path, 'ruby_ext', 'to_s2.rb')
require File.join(path, 'ruby_ext', 'calling_method.rb')
require File.join(path, 'zdate.rb')
require File.join(path, 'ztime.rb')
require File.join(path, 'instance_from_hash')
require File.join(path, 'query_constants')
require File.join(path, 'query')
require File.join(path, 'construct')
require File.join(path, 'construct_finder')
require File.join(path, 'construct_interpreter')
require File.join(path, 'occurrence')
require File.join(path, 'nlp.rb')

module Nickel
  class << self
    def parse(query, date_time = Time.now)
      n = NLP.new(query, date_time)
      n.parse
      n
    end
  end 
end
