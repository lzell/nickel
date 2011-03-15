# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module Nickel

  # TODO: get methods should accept dayname or dayindex
  class ZDate
    @days_of_week				= ["mon","tue","wed","thu","fri","sat","sun"]
    @full_days_of_week  = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    @months_of_year			= ["jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]
    @full_months_of_year = ["january","february","march","april","may","june","july","august","september","october","november","december"]
    @days_in_common_year_months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    @days_in_leap_year_months = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    MON = 0
    TUE = 1
    WED = 2
    THU = 3
    FRI = 4
    SAT = 5
    SUN = 6
     
    class << self
      attr_reader :days_of_week, :months_of_year, :days_in_common_year_months, :days_in_leap_year_months, :full_days_of_week, :full_months_of_year 
    end

    # Don't use attr_accessor for date, year, month, day; we want to validate on change.
    def initialize(yyyymmdd = nil)
      d = yyyymmdd ? yyyymmdd.dup : ::Time.new.strftime("%Y%m%d")
      d.gsub!(/-/,'') # remove any hyphens, so a user can initialize with something like "2008-10-23"
      self.date = d
    end
    
    def date
      @date
    end
    
    def date=(yyyymmdd)
      @date = yyyymmdd
      validate
    end

    def year_str
      @date[0..3]
    end
    
    def month_str
      @date[4..5]
    end
    
    def day_str
      @date[6..7]
    end
    
    def year
      year_str.to_i
    end
    
    def month
      month_str.to_i
    end
    
    def day
      day_str.to_i
    end
   
    def readable
      month_str + '/' + day_str + '/' + year_str
    end
    
    def fmt(txt)
      txt.gsub!(/%Y/, self.year_str)
      txt.gsub!(/%m/, self.month_str)
      txt.gsub!(/%d/, self.day_str)
    end
    
    def <(d2)
      (self.year < d2.year) || (self.year == d2.year && (self.month < d2.month || (self.month == d2.month && self.day < d2.day)))
    end
    
    def <=(d2)
      (self.year < d2.year) || (self.year == d2.year && (self.month < d2.month || (self.month == d2.month && self.day <= d2.day)))
    end
    
    def >(d2)
      (self.year > d2.year) || (self.year == d2.year && (self.month > d2.month || (self.month == d2.month && self.day > d2.day)))
    end
    
    def >=(d2)
      (self.year > d2.year) || (self.year == d2.year && (self.month > d2.month || (self.month == d2.month && self.day >= d2.day)))
    end
    
    def ==(d2)
      self.year == d2.year && self.month == d2.month && self.day == d2.day
    end
    
    def <=>(d2)
      if self < d2
        -1
      elsif self > d2
        1
      else
        0
      end
    end
    
    # returns true if self is today
    def is_today?
      self == ZDate.new
    end

    # for example, "1st friday", uses self as the reference month
    def ordinal_dayindex(num, day_index)
      # create a date object at the first occurrence of day_index
      first_occ_date = ZDate.new(year_str + month_str + "01").this(day_index)
      # if num is 1 through 4, we can just add (num-1) weeks
      if num <= 4
        d = first_occ_date.add_weeks(num - 1)
      else
        # we want the last occurrence of this month
        # add 4 weeks to first occurrence, see if we are in the same month, subtract 1 week if we are not
        d = first_occ_date.add_weeks(4)
        if d.month != self.month then d = d.sub_weeks(1) end
      end
      d
    end

    # for example, "this friday"
    def this(day)
      x_weeks_from_day(0, day)
    end
    
    # for example, "next friday"
    def next(day)
      x_weeks_from_day(1, day)
    end

    # for example, "previous friday"
    def prev(day)
      (self.dayindex == day) ? self.dup : x_weeks_from_day(-1,day)
    end
    
    # returns a new date object
    def x_weeks_from_day(weeks_away, day2index)
      day1index = self.dayindex
      if day1index > day2index
        days_away = 7 * (weeks_away + 1) - (day1index - day2index)
      elsif day1index < day2index
        days_away = (weeks_away * 7) + (day2index - day1index)
      elsif day1index == day2index
        days_away = 7 * weeks_away
      end
      self.add_days(days_away)  # returns a new date object
    end
    
    # add_ methods return new ZDate object, they DO NOT modify self
    def add_days(number)
      if number < 0 then return sub_days(number.abs) end
      o = self.dup  # new ZDate object
      # Let's see what month we are going to end in
      while number > 0
        if o.days_left_in_month >= number
          o.date = o.year_str + o.month_str + (o.day + number).to_s2
          number = 0
        else
          number = number - 1 - o.days_left_in_month  #it costs 1 day to increment the month
          o.increment_month!
        end
      end
      o
    end
    
    def add_weeks(number)
      self.add_days(7*number)
    end
    
    def add_months(number)
      new_month = 1 + ((month - 1 + number) % 12)
      if number > months_left_in_year            # are we going to change year?
        years_to_increment = 1 + ((number - months_left_in_year) / 12)    # second term adds years if user entered a large number of months (e.g. date.add_months(50))
      else
        years_to_increment = 0
      end
      new_year = year + years_to_increment
      new_day = get_day_or_max_day_in_month(self.day, new_month, new_year)
      ZDate.new(new_year.to_s + new_month.to_s2 + new_day.to_s2)
    end
    
    def add_years(number)
      new_year = year + number
      new_day = get_day_or_max_day_in_month(self.day, self.month, new_year)
      ZDate.new(new_year.to_s + self.month_str + new_day.to_s2)
    end

    # DEPRECATED, change_ methods in ZTime modify self, this was confusing,
    # change_ methods return new ZDate object, they DO NOT modify self
    # def change_year_to(y)
    #   o = ZDate.new(y.to_s + self.month_str + self.day_str)
    #   o
    # end
    # def change_day_to(d)
    #   o = ZDate.new(self.year_str + self.month_str + d.to_s2)
    #   o
    # end

    # returns new ZDate object, note this is the MONTH NUMBER, not MONTH INDEX from ZDate.months_of_year
    # returns the first day of the month
    def jump_to_month(month_number)
      # find difference in months
      if month_number >= self.month
        ZDate.new(year_str + (month_number).to_s2 + "01")
      else
        ZDate.new((year + 1).to_s + (month_number).to_s2 + "01")
      end
    end
    
    # beginning and end of month both return new ZDate objects
    def beginning_of_month
      ZDate.new(year_str + month_str + "01")
    end
    
    def end_of_month
      ZDate.new(year_str + month_str + self.days_in_month.to_s)
    end
    
    def beginning_of_next_month
      o = self.dup
      o.increment_month!
      o
    end

    # sub_ methods return new ZDate object, they do not modify self.
    def sub_days(number)
      o = self.dup
      while number > 0
        if (o.day - 1) >= number
          o.date = o.year_str + o.month_str + (o.day - number).to_s2
          number = 0
        else
          number = number - o.day
          o.decrement_month!
        end
      end
      o
    end
    
    def sub_weeks(number)
      self.sub_days(7 * number)
    end
    
    def sub_months(number)
      o = self.dup
      number.times do 
        o.decrement_month!
      end
      o
    end
  
    # Gets the absolute difference in days between self and date_to_compare, order is not important.
    def diff_in_days(date_to_compare)
      # d1 will be the earlier date, d2 the later
      if date_to_compare > self
        d1, d2 = self.dup, date_to_compare.dup
      elsif self > date_to_compare
        d1, d2 = date_to_compare.dup, self.dup
      else
        return 0  # same date
      end

      total = 0
      while d1.year != d2.year
        total += d1.days_left_in_year + 1 # need one extra day to push us to jan 1
        d1 = ZDate.new((d1.year + 1).to_s + "0101")
      end
      total += d2.day_of_year - d1.day_of_year
      total
    end
    
    def diff_in_days_to_this(closest_day_index)
   		if closest_day_index >= self.dayindex
   			closest_day_index - self.dayindex  # could be 0
   		else   # day_num < self.dayindex
   			7 - (self.dayindex - closest_day_index)
   		end
    end
  
    # We need days_in_months and diff_in_months to be available at the class level as well.
    class << self
      def new_first_day_in_month(month, year)
        ZDate.new(year.to_s + month.to_s2 + "01")
      end
      
      def new_last_day_in_month(month, year)
        day = days_in_month(month, year)
        ZDate.new(year.to_s + month.to_s2 + day.to_s2)
      end

      def days_in_month(month, year)
        if year % 400 == 0 || year % 4 == 0 && year % 100 != 0
          ZDate.days_in_leap_year_months[month - 1]
        else
          ZDate.days_in_common_year_months[month - 1]
        end
      end

      # Gets the difference FROM month1, year1 TO month2, year2
    	# don't use it the other way around, it won't work
    	def diff_in_months(month1, year1, month2, year2)
    		# first get the difference in months
    		if month2 >= month1
    			diff_in_months = month2 - month1
    		else
    			diff_in_months = 12 - (month1 - month2)
    			year2 -= 1  # this makes the next line nice
    		end
    		diff_in_months += (year2 - year1) * 12
    	end
    end
    
    # difference in months FROM self TO date2, for instance, if self is oct 1 and date2 is nov 14, will return 1
    # if self is nov 14 and date2 is oct 1, will return -1
    def diff_in_months(date2)
      if date2 > self
        ZDate.diff_in_months(self.month, self.year, date2.month, date2.year)
      else
        ZDate.diff_in_months(date2.month, date2.year, self.month, self.year) * -1
      end
    end
    
    def days_in_month
      if leap_year?
        ZDate.days_in_leap_year_months[self.month - 1]
      else
        ZDate.days_in_common_year_months[self.month - 1]
      end
    end
    
    def days_left_in_month
      self.days_in_month - self.day
    end
    
    def months_left_in_year
      12 - self.month
    end
    
    def dayname
      # well this is going to be a hack, I need an algo for finding the day
      # Ruby's Time.local is the fastest way to create a Ruby Time object
      t = ::Time.local(self.year, ZDate.months_of_year[self.month - 1], self.day)
      t.strftime("%a").downcase
    end
    
    def dayindex
      ZDate.days_of_week.index(self.dayname)
    end
    
    def full_dayname
      ZDate.full_days_of_week[self.dayindex]
    end
    
    def full_monthname
      Z.full_months_of_year[self.month - 1]
    end

    def leap_year?
      self.year % 400 == 0 || self.year % 4 == 0 && self.year % 100 != 0
    end
    
    def day_of_year
      doy = self.day
      # iterate through days in months arrays, summing up the days
      if leap_year?
        doy = (1...self.month).to_a.inject(doy) {|sum, n| sum += ZDate.days_in_leap_year_months[n-1]}
      else
        doy = (1...self.month).to_a.inject(doy) {|sum, n| sum += ZDate.days_in_common_year_months[n-1]}
      end
      doy
    end
    
    def days_left_in_year
      leap_year? ? 366 - self.day_of_year : 365 - self.day_of_year
    end
    
    def get_date_from_day_and_week_of_month(day_num, week_num)
      # This method is extremely sloppy, clean it up
  		# Get the index of the first day of this month
  		first_day_of_month = self.beginning_of_month
  		first_day_index = first_day_of_month.dayindex

      diff_in_days_to_first_occ = first_day_of_month.diff_in_days_to_this(day_num)

  		# now find the number of days to the correct occurrence; REMEMBER TO CHECK FOR LAST MONTH
  		if week_num == -1
  			total_diff_in_days = diff_in_days_to_first_occ + 21			# 7 * 3 weeks; are already at the first ocurrence, so this is total diff in days to 4th occurrence; may not be the last!!
  		else
  			total_diff_in_days = diff_in_days_to_first_occ + 7 * (week_num - 1)
  		end

  		# there is a chance that the last occurrence is not the 4th week of the month; if that is the case, add an extra 7 days
  		if (week_num == -1) && (self.month == self.beginning_of_month.add_days(total_diff_in_days + 7).month)
  			total_diff_in_days += 7
  		end

  		# Now we have the number of days FROM THE START OF THE CURRENT MONTH; if we are not past that date, then we have found the first occurrence
  		if (total_diff_in_days + 1) >= self.day
  			# Create occ_date_str and make sure it has two digits
  			occ_date_str = (total_diff_in_days + 1).to_s.gsub(/^(\d)$/,'0\1')
  			return self.beginning_of_month.add_days(total_diff_in_days)
  		else # We have already past the date; calculate the occurrence next month!
  			# Get the index of the first day next month
  			first_day_index = self.add_months(1).beginning_of_month.dayindex

  			# Find the number of days away to the day of interest (NOT the week)
  			if day_num > first_day_index
  				diff_in_days_to_first_occ = day_num - first_day_index
  			elsif day_num < first_day_index
  				diff_in_days_to_first_occ = 7 - (first_day_index - day_num)
  			else # first_day_index == day_num
  				diff_in_days_to_first_occ = 0
  			end

  			# now find the number of days to the correct occurrence; REMEMBER TO CHECK FOR LAST MONTH
  			if week_num == -1
  				total_diff_in_days = diff_in_days_to_first_occ + 21			# 7 * 3 weeks
  			else
  				total_diff_in_days = diff_in_days_to_first_occ + 7 * (week_num - 1)
  			end

  			# there is a chance that the last occurrence is not the 4th week of the month; if that is the case, add an extra 7 days
  			if (week_num == -1) && (self.add_months(1).month == self.add_months(1).beginning_of_month.add_days(total_diff_in_days + 7).month)
  				total_diff_in_days += 7
  			end

  			# Now we have the number of days FROM THE START OF THE NEXT MONTH; 
  			# Create occ_date_str and make sure it has two digits
  			return self.add_months(1).beginning_of_month.add_days(total_diff_in_days)
  		end # END if (total_diff_in_days + 1) ...
    end
    
    # returns a new ZDate object, NOTE! this returns nil if that date does not exist (sept 31st)
    def get_next_date_from_date_of_month(date_of_month)
      o = self.dup
      if day == date_of_month
        o
      else
        if day > date_of_month
          o.increment_month!
        end
        ZDate.new(o.year_str + o.month_str + date_of_month.to_s2) rescue nil
      end
    end

    protected
    # Modifies self.
    # bumps self to first day of next month
    def increment_month!
      if month != 12
        # just bump up a number
        self.date = year_str + (month + 1).to_s2 + "01"
      else
        self.date = (year + 1).to_s + "0101"
      end
    end

    def decrement_month!
      if month != 1
        # just bump down a number and set days to the last day in the month
        self.date = year_str + (month - 1).to_s2 + ZDate.days_in_month(month - 1, year).to_s2
      else
        self.date = (year - 1).to_s + "1231"    # dec has 31 days
      end
    end
    
    private
    def validate
      raise "ZDate says: invalid date" if !valid
    end
    
    def valid
      # It is important that valid_day is last because we have to do the days_in_month calculation!!!
      @date.length == 8 && @date !~ /\D/ && valid_year && valid_month && valid_day
    end
    
    def valid_year
      year >= 1900
    end
    
    def valid_month
      month >= 1 and month <= 12
    end
    
    def valid_day
      day >= 1 and day <= days_in_month
    end
    
    def get_day_or_max_day_in_month(day, month, year)
      # if day exists in month/year then use it, if it is not then use the last day of the month
      dm = ZDate.days_in_month(month, year)
      dm >= day ? day : dm
    end
  end
end
