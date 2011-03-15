# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module Nickel
  
  class ZTime
    # @firm will be used to indicate user provided am/pm
    attr_accessor :firm

    # @time is always stored on 24 hour clock, but we could initialize a Time object with ZTime.new("1020", :pm)
    # we will convert this to 24 hour clock and set @firm = true
    def initialize(hhmmss = nil, am_pm = nil)
      t = hhmmss ? hhmmss : ::Time.new.strftime("%H%M%S")
      t.gsub!(/:/,'') # remove any hyphens, so a user can initialize with something like "2008-10-23"
      self.time = t
      if am_pm then adjust_for(am_pm) end
    end

    def time
      @time
    end
    
    def time=(hhmmss)
      @time = lazy(hhmmss)
      @firm = false
      validate
    end

    def hour_str
      @time[0..1]
    end
    
    def minute_str
      @time[2..3]
    end
    
    def second_str
      @time[4..5]
    end
    
    def hour
      hour_str.to_i
    end
    
    def minute
      minute_str.to_i
    end
    
    def second
      second_str.to_i
    end

    # add_ methods return new ZTime object
    # add_ methods take an optional block, the block will be passed the number of days that have passed; 
    # i.e. adding 48 hours will pass a 2 to the block, this is handy for something like this:
    # time.add_hours(15) {|x| date.add_days(x)}
    def add_minutes(number, &block)
      # new minute is going to be (current minute + number) % 60
      # number of hours to add is (current minute + number) / 60
      hours_to_add = (self.minute + number) / 60
      # note add_hours returns a new time object
      if block_given?
        o = self.add_hours(hours_to_add, &block)
      else
        o = self.add_hours(hours_to_add)
      end
      o.change_minute_to((o.minute + number) % 60)  # modifies self
    end
    
    def add_hours(number, &block)
      o = self.dup
      if block_given?
        yield((o.hour + number) / 24)
      end
      o.change_hour_to((o.hour + number) % 24)
    end


    # NOTE: change_ methods modify self.
    def change_hour_to(h)
      self.time = h.to_s2 + minute_str + second_str
      self
    end
    
    def change_minute_to(m)
      self.time = hour_str + m.to_s2 + second_str
      self
    end
    
    def change_second_to(s)
      self.time = hour_str + minute_str + s.to_s2
      self
    end

    def readable
      @time[0..1] + ":" + @time[2..3] + ":" + @time[4..5]
    end
    
    def readable_12hr
      hour_on_12hr_clock.to_s2 + ":" + @time[2..3] + " #{am_pm}"
    end
    
    def hour_on_12hr_clock
      h = hour % 12 
      h += 12 if h == 0
      h
    end
    
    def is_am?
      hour < 12   # 0 through 11 on 24hr clock
    end
    
    def am_pm
      is_am? ? "am" : "pm"
    end
    

    def <(t2)
      (self.hour < t2.hour) || (self.hour == t2.hour && (self.minute < t2.minute || (self.minute == t2.minute && self.second < t2.second)))
    end
    
    def <=(t2)
      (self.hour < t2.hour) || (self.hour == t2.hour && (self.minute < t2.minute || (self.minute == t2.minute && self.second <= t2.second)))
    end
    
    def >(t2)
      (self.hour > t2.hour) || (self.hour == t2.hour && (self.minute > t2.minute || (self.minute == t2.minute && self.second > t2.second)))
    end
    
    def >=(t2)
      (self.hour > t2.hour) || (self.hour == t2.hour && (self.minute > t2.minute || (self.minute == t2.minute && self.second >= t2.second)))
    end
    
    def ==(t2)
      self.hour == t2.hour && self.minute == t2.minute && self.second == t2.second
    end
    
    def <=>(t2)
      if self < t2
        -1
      elsif self > t2
        1
      else
        0
      end
    end
    
    class << self

      # send an array of ZTime objects, this will make a guess at whether they should be am/pm if the user did not specify
      # NOTE ORDER IS IMPORTANT: times[0] is assumed to be BEFORE times[1]
      def am_pm_modifier(*time_array)
        # find firm time indices
        firm_time_indices = []
        time_array.each_with_index {|t,i| firm_time_indices << i if t.firm}
        
        if firm_time_indices.empty?
          # pure guess
          # DO WE REALLY WANT TO DO THIS?
          time_array.each_index do |i|
            # user gave us nothing
            next if i == 0
            time_array[i].guess_modify_such_that_is_after(time_array[i-1])
          end
        else
          # first handle soft times up to first firm time
          min_boundary = 0
          max_boundary = firm_time_indices[0]
          (min_boundary...max_boundary).to_a.reverse.each do |i|      # this says, iterate backwards starting from max_boundary, but not including it, until the min boundary
            time_array[i].modify_such_that_is_before(time_array[i+1])
          end
          
          firm_time_indices.each_index do |j|
            # now handle all times after first firm time until the next firm time
            min_boundary = firm_time_indices[j]
            max_boundary = firm_time_indices[j+1] || time_array.size
            (min_boundary + 1...max_boundary).each do |i|     # any boundary problems here? What if there is only 1 time?  Nope.
              time_array[i].modify_such_that_is_after(time_array[i-1])
            end
          end
        end
      end

      def am_to_24hr(h)
        # note 12am is 00
        h % 12
      end
      
      def pm_to_24hr(h)
        h == 12 ? 12 : h + 12
      end
    end

    # this can very easily be cleaned up
    def modify_such_that_is_before(time2)
      raise "ZTime#modify_such_that_is_before says: trying to modify time that has @firm set" if @firm
      raise "ZTime#modify_such_that_is_before says: time2 does not have @firm set" if !time2.firm
      # self cannot have @firm set, so all hours will be between 1 and 12
      # time2 is an end time, self could be its current setting, or off by 12 hours
      
      # self to time2 --> self to time2
      # 12   to 2am   --> 1200 to 0200
      # 12   to 12am  --> 1200 to 0000
      # 1220 to 12am  --> 1220 to 0000
      # 11 to 2am  or 1100 to 0200
      if self > time2
        if self.hour == 12 && time2.hour == 0
          # do nothing
        else
          self.hour == 12 ? change_hour_to(0) : change_hour_to(self.hour + 12)
        end
      elsif self < time2
        if time2.hour >= 12 && ZTime.new((time2.hour - 12).to_s2 + time2.minute_str + time2.second_str) > self
          # 4 to 5pm  or 0400 to 1700
          change_hour_to(self.hour + 12)
        else
          # 4 to 1pm  or 0400 to 1300
          # do nothing
        end
      else
        # the times are equal, and self can only be between 0100 and 1200, so move self forward 12 hours, unless hour is 12
        self.hour == 12 ? change_hour_to(0) : change_hour_to(self.hour + 12)
      end
      self.firm = true
      self
    end
    
    def modify_such_that_is_after(time1)
      raise "ZTime#modify_such_that_is_after says: trying to modify time that has @firm set" if @firm
      raise "ZTime#modify_such_that_is_after says: time1 does not have @firm set" if !time1.firm
      # time1 to self --> time1 to self
      # 8pm   to 835  --> 2000 to 835
      # 835pm to 835  --> 2035 to 835
      # 10pm  to 11   --> 2200 to 1100
      # 1021pm to 1223--> 2221 to 1223
      # 930am  to 5 --->  0930 to 0500
      # 930pm  to 5 --->  2130 to 0500
      if self < time1
        unless time1.hour >= 12 && ZTime.new((time1.hour - 12).to_s2 + time1.minute_str + time1.second_str) >= self
          self.hour == 12 ? change_hour_to(0) : change_hour_to(self.hour + 12)
        end
      elsif self > time1
        # # time1 to self --> time1 to self
        # # 10am  to 11   --> 1000  to 1100
        # # 
        # if time1.hour >= 12 && ZTime.new((time1.hour - 12).to_s2 + time1.minute_str + time1.second_str) > self
        #   change_hour_to(self.hour + 12)
        # else
        #   # do nothing
        # end
      else
        # the times are equal, and self can only be between 0100 and 1200, so move self forward 12 hours, unless hour is 12
        self.hour == 12 ? change_hour_to(0) : change_hour_to(self.hour + 12)
      end
      self.firm = true
      self
    end

    # use this if we don't have a firm time to modify off
    def guess_modify_such_that_is_after(time1)
      # time1 to self    time1 to self
      # 9    to    5 --> 0900 to 0500
      # 9   to     9 --> 0900 to 0900
      # 12   to   12 --> 1200 to 1200
      # 12 to 6   --->   1200 to 0600
      if time1 >= self
        # crossed boundary at noon
        self.hour == 12 ? change_hour_to(0) : change_hour_to(self.hour + 12)
      end
    end
    
    private
    
    def adjust_for(am_pm)
      # how does validation work?  Well, we already know that @time is valid, and once we modify we call time= which will
      # perform validation on the new time.  That won't catch something like this though:  ZTime.new("2215", :am)
      # so we will check for that here.
      # If user is providing :am or :pm, the hour must be between 1 and 12
      raise "ZTime#adjust_for says: you specified am or pm with 1 > hour > 12" unless hour >= 1 && hour <= 12
      if am_pm == :am || am_pm == 'am'
        change_hour_to(ZTime.am_to_24hr(self.hour))
      elsif am_pm == :pm || am_pm == 'pm'
        change_hour_to(ZTime.pm_to_24hr(self.hour))
      else
        raise "ZTime#adjust_for says: you passed an invalid value for am_pm, use :am or :pm"
      end
      @firm = true
    end
    
    def validate
      raise "ZTime#validate says: invalid time" unless valid
    end
    
    def valid
      @time.length == 6 && @time !~ /\D/ && valid_hour && valid_minute && valid_second
    end
    
    def valid_hour
      hour >= 0 and hour < 24
    end
    
    def valid_minute
      minute >= 0 and minute < 60
    end
    
    def valid_second
      second >= 0 and second < 60
    end
    
    def lazy(s)
      # someone isn't following directions, but we will let it slide
      s.length == 1 && s = "0#{s}0000"        # only provided h
      s.length == 2 && s << "0000"            # only provided hh
      s.length == 4 && s << "00"              # only provided hhmm
      return s
    end
  end
end
