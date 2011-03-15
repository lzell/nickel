module Compare

  # Use this to compare two objects, it will check their classes, instance vars, methods and instance var values
  # to make sure the objects are "the same", they DO NOT have to share the same object_id, that's the point.
  # NOTE: This won't work on any base classes (e.g. String, Fixnum, Array)
  # I could put in a quick fix, it would check for base class and then just use "==" operator
  class Objects

    def initialize(object1, object2)
      @o1, @o2 = object1, object2
    end

    # class level access
    class << self
      def same?(object1, object2)
        new(object1, object2).same?
      end
    end

    def same?
      same_class? && same_content?
    end

    def same_class?
      @o1.class.name == @o2.class.name
    end

    def same_content?
      if @o1.class.name =~ /Array|Fixnum|Hash|String/
        @o1 == @o2
      else
        same_methods? && same_instance_variables? && same_instance_variable_values?
      end
    end

    def same_methods?
      # @o1.methods == @o2.methods  WOW! that was a bug, [1,2] is not the same as [2,1]  <-- I find it hard to believe I didn't know this!
      @o1.methods.sort == @o2.methods.sort 
    end

    def same_instance_variables?
      # @o1.instance_variables == @o2.instance_variables    # BAD BAD BAD
      @o1.instance_variables.sort == @o2.instance_variables.sort
    end

    def same_instance_variable_values?
      same = true
      @o1.instance_variables.each do |ivar|
        o1_var_val = @o1.instance_variable_get(ivar)
        o2_var_val = @o2.instance_variable_get(ivar)
        if o1_var_val == o2_var_val   # if they are the same by "==" operator, we are fine, note that Z::Time now has == so it won't go through recursion, meaning we may miss @firm setting
        elsif o1_var_val.class.name !~ /Array|Fixnum|Hash|String/ && Objects.same?(o1_var_val, o2_var_val)  # instance vars are objects other than base class! Recursion!
        else
          same = false  # no match by "==" or by compare objects
        end
      end
      return same
    end
  end

  # Use this to compare an array of objects, e.g. [object1, object2] and [object3, object4]
  # note order is not important, both of these cases would return true:
  # object1 same as object3
  # object2 same as object4
  # OR
  # object1 same as object4
  # object2 same as object3
  class ArrayofObjects

    def initialize(array1, array2)
      @a1, @a2 = array1.dup, array2.dup
    end

    class << self
      def same?(array1, array2)
        new(array1, array2).same?
      end
    end

    def same?
      equal_size? && equal_objects?
    end

    def equal_size?
      @a1.size == @a2.size
    end

    def equal_objects?
      same = true
      @a1.size.times do
        unless first_element_in_a1_has_match_in_a2 then same = false end
      end
      same
    end

    def first_element_in_a1_has_match_in_a2
      has_match = false
      @a2.size.times do |i|
        if Objects.same?(@a1[0], @a2[i])
          has_match = true
          @a1.shift   # we are removing the matching elements from @a1 and @a2 so they don't match anything else in next iterations
          @a2.delete_at(i)
          break
        end
      end
      has_match
    end
  end
end
