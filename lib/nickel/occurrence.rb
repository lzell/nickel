# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module Nickel

  class Occurrence
    include InstanceFromHash

    # Some notes about this class, @type can take the following values:
    # :single, :daily, :weekly, :daymonthly, :datemonthly,
    attr_accessor :type, :start_date, :end_date, :start_time, :end_time, :interval, :day_of_week, :week_of_month, :date_of_month
    
    def initialize(h)
      @start_date = nil     # prevents warning in testing;  but why is the warning there in the first place? Because I should be using instance_variable_defined in finalize method instead of checking for nil vals
      super(h)
    end
    
    def inspect
      str = %(\#<Occurrence type: #{type})
      str << %(, start_date: "#{start_date.date}")  if start_date
      str << %(, end_date: "#{end_date.date}")      if end_date
      str << %(, start_time: "#{start_time.time}")  if start_time
      str << %(, end_time: "#{end_time.time}")      if end_time
      str << %(, interval: #{interval})             if interval
      str << %(, day_of_week: #{day_of_week})       if day_of_week
      str << %(, week_of_month: #{week_of_month})   if week_of_month
      str << %(, date_of_month: #{date_of_month})   if date_of_month
      str << ">"
      str
    end
    
    
    def finalize(cur_date)
      #@end_date = nil if @end_date.nil?
      # one of the purposes of this method is to find a start date if it is not already specified

      # case type 
      #   when :daily then finalize_daily
      #   when :weekly then finalize_weekly
      #   when :daymonthly then finalize_daymonthly
      #   when :datemonthly then finalize_datemonthly
      # end
      
      
      if @type == :daily && @start_date.nil?
        @start_date = cur_date
      elsif @type == :weekly
        if @start_date.nil?
          @start_date = cur_date.this(@day_of_week)
        else
          @start_date = @start_date.this(@day_of_week)     # this is needed in case someone said "every monday and wed starting DATE"; we want to find the first occurrence after DATE
        end
        if instance_variable_defined?("@end_date")
          @end_date = @end_date.prev(@day_of_week)        # find the real end date, if someone says "every monday until dec 1"; find the actual last occurrence
        end
      elsif @type == :datemonthly
        if @start_date.nil?
          if cur_date.day <= @date_of_month
            @start_date = cur_date.add_days(@date_of_month - cur_date.day)
          else
            @start_date = cur_date.add_months(1).beginning_of_month.add_days(@date_of_month - 1)
          end
        else
          if @start_date.day <= @date_of_month
            @start_date = @start_date.add_days(@date_of_month - @start_date.day)
          else
            @start_date = @start_date.add_months(1).beginning_of_month.add_days(@date_of_month - 1)
          end
        end
      elsif @type == :daymonthly
        # in this case we also want to change @week_of_month val to -1 if it is currently 5.  I used 5 to represent "last" in the previous version of the parser, but a more standard format is to use -1
        @week_of_month = -1 if @week_of_month == 5
        if @start_date.nil?
          @start_date = cur_date.get_date_from_day_and_week_of_month(@day_of_week, @week_of_month)
        else
          @start_date = @start_date.get_date_from_day_and_week_of_month(@day_of_week, @week_of_month)
        end
      end
      
    end

    class << self
      def finalizer(occurrences, cur_date)
        occurrences.each {|occ| occ.finalize(cur_date)}
        occurrences
      end
    end
  end
end
