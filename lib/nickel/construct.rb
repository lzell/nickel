# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module Nickel

  class Construct
    include InstanceFromHash
    attr_accessor :comp_start, :comp_end, :found_in
  end

  class DateConstruct < Construct
    attr_accessor :date
    def interpret
      {:date => @date}
    end
  end

  class DateSpanConstruct < Construct
    attr_accessor :start_date, :end_date
  end

  class TimeConstruct < Construct
    attr_accessor :time
    def interpret
      {:time => @time}
    end
  end

  class TimeSpanConstruct < Construct
    attr_accessor :start_time, :end_time
  end

  class WrapperConstruct < Construct
    attr_accessor :wrapper_type, :wrapper_length
  end

  class RecurrenceConstruct < Construct
    attr_accessor :repeats, :repeats_on
    
    def interpret
      if    variant_of?(:daily)       then interpret_daily_variant
      elsif variant_of?(:weekly)      then interpret_weekly_variant
      elsif variant_of?(:daymonthly)  then interpret_daymonthly_variant
      elsif variant_of?(:datemonthly) then interpret_datemonthly_variant
      else
        puts @repeats.inspect
        raise StandardError.new("self is an invalid variant, check value of self.repeats or @repeats")
      end
    end
    
    def get_interval
      if    has_interval_of?(1)  then 1
      elsif has_interval_of?(2)  then 2
      elsif has_interval_of?(3)  then 3
      else
        raise StandardError.new("self.repeats is invalid!!")
      end
    end

    private
    def has_interval_of?(x)
      case x
      when 1 then [:daily, :weekly, :daymonthly, :datemonthly].include?(@repeats)
      when 2 then [:altdaily, :altweekly, :altdaymonthly, :altdatemonthly].include?(@repeats)
      when 3 then [:threedaily, :threeweekly, :threedaymonthly, :threedatemonthly].include?(@repeats)
      end
    end

    def variant_of?(sym)
      case sym
      when :daily       then [:daily, :altdaily, :threedaily].include?(@repeats)
      when :weekly      then [:weekly, :altweekly, :threeweekly].include?(@repeats)
      when :daymonthly  then [:daymonthly, :altdaymonthly, :threedaymonthly].include?(@repeats)
      when :datemonthly then [:datemonthly, :altdatemonthly, :threedatemonthly].include?(@repeats)
      end
    end

    def interpret_daily_variant
      hash_for_occ_base = {:type => :daily, :interval => get_interval}
      [hash_for_occ_base]
    end

    # @repeats_on is an array of day indices. For example,
    # "every monday and wed" will produce @repeats_on == [0,2].
    def interpret_weekly_variant
      hash_for_occ_base = {:type => :weekly, :interval => get_interval}
      array_of_occurrences = []
      @repeats_on.each do |day_of_week|
        array_of_occurrences << hash_for_occ_base.merge({:day_of_week => day_of_week})
      end
      array_of_occurrences
    end

    # @repeats_on is an array of arrays: Each sub array has the format
    # [week_of_month, day_of_week].  For example, 
    # "the first and second sat of every month" will produce
    # @repeats_on == [[1,5], [2,5]]
    def interpret_daymonthly_variant
      hash_for_occ_base = {:type => :daymonthly, :interval => get_interval}
      array_of_occurrences = []
      @repeats_on.each do |on|
        h = {:week_of_month => on[0], :day_of_week => on[1]}
        array_of_occurrences << hash_for_occ_base.merge(h)
      end
      array_of_occurrences
    end

    # @repeats_on is an array of datemonthly indices.  For example, 
    # "the 21st and 22nd of every monthy" will produce @repeats_on == [21, 22]
    def interpret_datemonthly_variant
      hash_for_occ_base = {:type => :datemonthly, :interval => get_interval}
      array_of_occurrences = []
      @repeats_on.each do |date_of_month|
        h = {:date_of_month => date_of_month}
        array_of_occurrences << hash_for_occ_base.merge(h)
      end
      array_of_occurrences
    end
  end
end
