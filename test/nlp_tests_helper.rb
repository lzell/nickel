require File.join(File.dirname(__FILE__), 'compare.rb')
require 'pp'

module NLPTestsHelper
  
  # Removing pretty print and pretty_inspect dramatically improves test time.
  PRETTY = false

  def assert_nlp(nlpobj, occ_array)
    nlp_occ_array = nlpobj.parse
    inspect_method = PRETTY ? :pretty_inspect : :inspect
    compare = Compare::ArrayofObjects.new(nlp_occ_array, occ_array)
    err_msg = "\n\n\e[44mExpected\e[0m\n " + occ_array.send(inspect_method) + 
              "\n\n\e[44mGot\e[0m\n " + nlp_occ_array.send(inspect_method) + 
              "\n\n" + nlpobj.debug_str(inspect_method)
    assert_block(err_msg){ compare.same? }
  end

  def assert_message(nlpobj, expected_message)
    nlpobj.parse
    message = nlpobj.message
    err_msg = "\n\nQuery:\n" + nlpobj.query +
              "\n\n\e[44mExpected Message\e[0m\n" + expected_message.inspect + 
              "\n\n\e[44mGot\e[0m\n" + message.inspect
    assert_block(err_msg){ message == expected_message }
  end
end



# Could use this instead of test/unit 
# class Testis
#   def initialize
#     #find all methods with test_ and run them
#     methods_to_run = self.methods.select {|mname| mname =~ /^test_/}
#     methods_to_run.each do |meth|
#       eval(meth)
#     end
#   end
# 
#   def assert_nlp(nlpobj, occ_array)
#     nlp_occ_array = nlpobj.parse
#     compare = Compare::ArrayofObjects.new(nlp_occ_array.dup, occ_array.dup)
#     cval = compare.same?
#     puts cval
#     if !cval
#       puts nlp_occ_array.inspect
#       puts "\n\n\n"
#       puts occ_array.inspect
#     end
#   end
# end



