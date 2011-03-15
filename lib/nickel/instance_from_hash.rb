# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module InstanceFromHash

  def initialize(h)
    h.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
    super()
  end
end
