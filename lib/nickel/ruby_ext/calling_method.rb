module Kernel
private
  def method_name
    caller[0] =~ /`([^']*)'/ and $1
  end
  def calling_method
    md = caller[1].match(/(\d+):in `([^']*)'/)
    md && "#{md[2]}:#{md[1]}"
  end
end
