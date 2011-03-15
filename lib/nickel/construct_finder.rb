# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module Nickel

  class ConstructFinder
    attr_reader :constructs, :components
    
    def initialize(query, curdate, curtime)
      # If query is a string (for debug), use it to initialize NLPQuery.
      query.class == String && query = NLPQuery.new(query)    
      @curdate = curdate
      @curtime = curtime
      @components = query.split
      @pos = 0    # iterator
      @constructs = []
    end
    
    def run
      while @pos < @components.size
        big_if_on_current_word
        @pos += 1
      end
    end
          
    def reset_instance_vars
      @day_index = nil
      @month_index = nil
      @week_num = nil
      @date_array = nil
      @length = nil
      @time1 = nil
      @time2 = nil
      @date1 = nil
      @date2 = nil
    end
    
    def big_if_on_current_word
      reset_instance_vars
      
      if match_every
          if match_every_dayname                          then  found_every_dayname                           # every tue
          elsif match_every_day                           then  found_every_day                               # every day
          elsif match_every_other                                                                             
            if    match_every_other_dayname               then  found_every_other_dayname                     # every other fri
            elsif match_every_other_day                   then  found_every_other_day                         # every other day
            end                                                                                               
          elsif match_every_3rd                                                                               
            if    match_every_3rd_dayname                 then  found_every_3rd_dayname                       # every third fri
            elsif match_every_3rd_day                     then  found_every_3rd_day                           # every third day
            end                                                                                               
          end                                                                                                 
                                                                                                              
      elsif match_repeats                                                                                     
          if match_repeats_daily                          then  found_repeats_daily                           # repeats daily
          elsif match_repeats_altdaily                    then  found_repeats_altdaily                        # repeats altdaily
          elsif match_repeats_weekly_vague                then  found_repeats_weekly_vague                    # repeats weekly
          elsif match_repeats_altweekly_vague             then  found_repeats_altweekly_vague                 # repeats altweekly
          elsif match_repeats_monthly                                                                         
            if match_repeats_daymonthly                   then  found_repeats_daymonthly                      # repeats monthly 1st fri
            elsif match_repeats_datemonthly               then  found_repeats_datemonthly                     # repeats monthly 22nd
            end                                                                                               
          elsif match_repeats_altmonthly                                                                      
            if match_repeats_altmonthly_daymonthly        then  found_repeats_altmonthly_daymonthly           # repeats altmonthly 1st fri
            elsif match_repeats_altmonthly_datemonthly    then  found_repeats_altmonthly_datemonthly          # repeats altmonthly 22nd
            end                                                                                               
          elsif match_repeats_threemonthly                                                                    
            if match_repeats_threemonthly_daymonthly      then  found_repeats_threemonthly_daymonthly         # repeats threemonthly 1st fri
            elsif match_repeats_threemonthly_datemonthly  then  found_repeats_threemonthly_datemonthly        # repeats threemonthly 22nd
            end                                                                                               
          end                                                                                                 
                                                                                                              
      elsif match_for_x                                                                                       
          if match_for_x_days                             then  found_for_x_days                              # for 10 days
          elsif match_for_x_weeks                         then  found_for_x_weeks                             # for 10 weeks
          elsif match_for_x_months                        then  found_for_x_months                            # for 10 months
          end                                                                                                 
                                                                                                              
      elsif match_this                                                                                        
          if match_this_dayname                           then  found_this_dayname                            # this fri
          elsif match_this_week                           then  found_this_week                               # this week
          elsif match_this_month                          then  found_this_month                              # this month (implies 9/1 to 9/30)
          end                                                                                                 # SHOULDN'T "this" HAVE "this weekend" ??? 
                                                                                                              
      elsif match_next                                                                                        
          if match_next_weekend                           then  found_next_weekend                            # next weekend --- never hit?
          elsif match_next_dayname                        then  found_next_dayname                            # next tuesday
          elsif match_next_x                                                                                  
            if    match_next_x_days                       then  found_next_x_days                             # next 5 days   --- shouldn't this be a wrapper?
            elsif match_next_x_weeks                      then  found_next_x_weeks                            # next 5 weeks  --- shouldn't this be a wrapper?
            elsif match_next_x_months                     then  found_next_x_months                           # next 5 months --- shouldn't this be a wrapper?
            elsif match_next_x_years                      then  found_next_x_years                            # next 5 years  --- shouldn't this be a wrapper?
            end                                                                                               
          elsif match_next_week                           then  found_next_week
          elsif match_next_month                          then  found_next_month                              # next month (implies 10/1 to 10/31)
          end                                                                                                 
      
      elsif match_week
          if match_week_of_date                           then  found_week_of_date                            # week of 1/2
          elsif match_week_through_date                   then  found_week_through_date                       # week through 1/2  (as in, week ending 1/2)
          end
                                                                                                              
      elsif match_x_weeks_from                                                                                
          if match_x_weeks_from_dayname                   then  found_x_weeks_from_dayname                    # 5 weeks from tuesday
          elsif match_x_weeks_from_this_dayname           then  found_x_weeks_from_this_dayname               # 5 weeks from this tuesday
          elsif match_x_weeks_from_next_dayname           then  found_x_weeks_from_next_dayname               # 5 weeks from next tuesday
          elsif match_x_weeks_from_tomorrow               then  found_x_weeks_from_tomorrow                   # 5 weeks from tomorrow
          elsif match_x_weeks_from_now                    then  found_x_weeks_from_now                        # 5 weeks from now
          elsif match_x_weeks_from_yesterday              then  found_x_weeks_from_yesterday                  # 5 weeks from yesterday
          end                                                                                                 
                                                                                                              
      elsif match_x_months_from                                                                               
          if match_x_months_from_dayname                  then  found_x_months_from_dayname                   # 2 months from wed
          elsif match_x_months_from_this_dayname          then  found_x_months_from_this_dayname              # 2 months from this wed
          elsif match_x_months_from_next_dayname          then  found_x_months_from_next_dayname              # 2 months from next wed
          elsif match_x_months_from_tomorrow              then  found_x_months_from_tomorrow                  # 2 months from tomorrow
          elsif match_x_months_from_now                   then  found_x_months_from_now                       # 2 months from now
          elsif match_x_months_from_yesterday             then  found_x_months_from_yesterday                 # 2 months from yesterday
          end                                                                                                 
                                                                                                              
      elsif match_x_days_from                                                                                 
          if match_x_days_from_now                        then  found_x_days_from_now                         # 5 days from now
          elsif match_x_days_from_dayname                 then  found_x_days_from_dayname                     # 5 days from monday
          end                                                                                                 
                                                                                                              
      elsif match_x_dayname_from                                                                              
          if match_x_dayname_from_now                     then  found_x_dayname_from_now                      # 2 fridays from now
          elsif match_x_dayname_from_tomorrow             then  found_x_dayname_from_tomorrow                 # 2 fridays from tomorrow
          elsif match_x_dayname_from_yesterday            then  found_x_dayname_from_yesterday                # 2 fridays from yesterday
          elsif match_x_dayname_from_this                 then  found_x_dayname_from_this                     # 2 fridays from this one
          elsif match_x_dayname_from_next                 then  found_x_dayname_from_next                     # 2 fridays from next friday
          end                                                                                                 

      elsif match_x_minutes_from_now                      then  found_x_minutes_from_now                      # 5 minutes from now
      elsif match_x_hours_from_now                        then  found_x_hours_from_now                        # 5 hours from now

      elsif match_ordinal_dayname                                                                             
          if match_ordinal_dayname_this_month             then  found_ordinal_dayname_this_month              # 2nd friday this month
          elsif match_ordinal_dayname_next_month          then  found_ordinal_dayname_next_month              # 2nd friday next month
          elsif match_ordinal_dayname_monthname           then  found_ordinal_dayname_monthname               # 2nd friday december
          end                                                                                                 
                                                                                                              
      elsif match_ordinal_this_month                      then  found_ordinal_this_month                      # 28th this month
      elsif match_ordinal_next_month                      then  found_ordinal_next_month                      # 28th next month
      
      elsif match_first_day                                                                                   
          if match_first_day_this_month                   then  found_first_day_this_month                    # first day this month
          elsif match_first_day_next_month                then  found_first_day_next_month                    # first day next month
          elsif match_first_day_monthname                 then  found_first_day_monthname                     # first day january (well this is stupid, "first day of january" gets preprocessed into "1/1", so what is the point of this?)
          end                                                                                                 
                                                                                                              
      elsif match_last_day                                                                                    
          if match_last_day_this_month                    then  found_last_day_this_month                     # last day this month
          elsif match_last_day_next_month                 then  found_last_day_next_month                     # last day next month
          elsif match_last_day_monthname                  then  found_last_day_monthname                      # last day november
          end                                                                                                 
                                                                                                              
      elsif match_at                                                                                          
          if match_at_time                                                                                    
            if match_at_time_through_time                 then  found_at_time_through_time                    # at 2 through 5pm
            else                                                found_at_time                                 # at 2
            end                                                                                               
          end                                                                                                 
                                                                                                              
      elsif match_all_day                                 then  found_all_day                                 # all day
                                                                                                              
      elsif match_tomorrow                                                                                    
          if match_tomorrow_through                                                                           
            if match_tomorrow_through_dayname             then  found_tomorrow_through_dayname                # tomorrow through friday
            elsif match_tomorrow_through_date             then  found_tomorrow_through_date                   # tomorrow through august 20th
            end                                                                                               
          else                                                  found_tomorrow                                # tomorrow
          end                                                                                                 
                                                                                                              
      elsif match_now                                                                                         
          if match_now_through                                                                                
            if match_now_through_dayname                  then  found_now_through_dayname                     # today through friday
            elsif match_now_through_following_dayname     then  found_now_through_following_dayname           # REDUNDANT, PREPROCESS THIS OUT
            elsif match_now_through_date                  then  found_now_through_date                        # today through 10/1
            elsif match_now_through_tomorrow              then  found_now_through_tomorrow                    # today through tomorrow
            elsif match_now_through_next_dayname          then  found_now_through_next_dayname                # today through next friday
            end                                                                                               
          else                                                  found_now                                     # today
          end                                                   
                                                                
      elsif match_dayname                                                                                     
          if match_dayname_the_ordinal                    then  found_dayname_the_ordinal                     # monday the 21st
          elsif match_dayname_x_weeks_from_next           then  found_dayname_x_weeks_from_next               # monday 2 weeks from next
          elsif match_dayname_x_weeks_from_this           then  found_dayname_x_weeks_from_this               # monday 2 weeks from this
          else                                                  found_dayname                                 # monday (also monday tuesday wed...)
          end 
      
      elsif match_through_monthname                       then  found_through_monthname                       # through december (implies through 11/30)
      elsif match_monthname                               then  found_monthname                               # december (implies 12/1 to 12/31)
                                                                
      # 5th constructor                                         
      elsif match_start                                   then  found_start
      elsif match_through                                 then  found_through
                                                        
      elsif match_time                                    # match time second to last
          if match_time_through_time                      then  found_time_through_time                       # 10 to 4
          else                                                  found_time                                    # 10
          end
          
      elsif match_date                                    # match date last
          if match_date_through_date                      then  found_date_through_date                       # 5th through the 16th
          else                                                  found_date                                    # 5th
          end
      end
    end # end def big_if_on_current_word

    def match_every
      @components[@pos]=="every"
    end
    
    def match_every_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+1])     # if "every [day]"
    end
    
    def found_every_dayname
      day_array=[@day_index]
      j = 2
      while @components[@pos+j] && ZDate.days_of_week.index(@components[@pos+j]) # if "every mon tue wed"
        day_array << ZDate.days_of_week.index(@components[@pos+j])
        j += 1
      end
      @constructs << RecurrenceConstruct.new(:repeats => :weekly, :repeats_on => day_array, :comp_start => @pos, :comp_end => @pos += (j - 1), :found_in => method_name)
    end
    
    def match_every_day
      @components[@pos+1] == "day"
    end
    
    def found_every_day
      @constructs << RecurrenceConstruct.new(:repeats => :daily, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end

    def match_every_other
      @components[@pos+1] =~ /other|2nd/
    end
    
    def match_every_other_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+2])      # if "every other mon"
    end
    
    def found_every_other_dayname
      day_array = [@day_index]
      j = 3
      while @components[@pos+j] && ZDate.days_of_week.index(@components[@pos+j])  #if "every other mon tue wed
        day_array << ZDate.days_of_week.index(@components[@pos+j])
        j += 1
      end
      @constructs << RecurrenceConstruct.new(:repeats => :altweekly, :repeats_on => day_array, :comp_start => @pos, :comp_end => @pos += (j - 1), :found_in => method_name)
    end
    
    def match_every_other_day
      @components[@pos+2] == "day"       ##  if "every other day"
    end
    
    def found_every_other_day
      @constructs << RecurrenceConstruct.new(:repeats => :altdaily, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_every_3rd
      @components[@pos+1] == "3rd"
    end
    
    def match_every_3rd_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+2])      # if "every 3rd tue"
    end
    
    def found_every_3rd_dayname
      day_array = [@day_index]
      j = 3
      while @components[@pos+j] && ZDate.days_of_week.index(@components[@pos+j])  #if "every 3rd tue wed thu
        day_array << ZDate.days_of_week.index(@components[@pos+j])
        j += 1
      end
      @constructs << RecurrenceConstruct.new(:repeats => :threeweekly, :repeats_on => day_array, :comp_start => @pos, :comp_end => @pos += (j - i), :found_in => method_name)
    end
    
    def match_every_3rd_day
      @components[@pos+2] == "day"       ##  if "every 3rd day"
    end
    
    def found_every_3rd_day
      @constructs << RecurrenceConstruct.new(:repeats => :threedaily, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_repeats
      @components[@pos] == "repeats"
    end
    
    def match_repeats_daily
      @components[@pos+1] == "daily"        
    end

    def found_repeats_daily
      @constructs << RecurrenceConstruct.new(:repeats => :daily, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end

    def match_repeats_altdaily
      @components[@pos+1] == "altdaily"
    end

    def found_repeats_altdaily
      @constructs << RecurrenceConstruct.new(:repeats => :altdaily, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end

    def match_repeats_weekly_vague
      @components[@pos+1] == "weekly"
    end

    def found_repeats_weekly_vague
      @constructs << RecurrenceConstruct.new(:repeats => :weekly, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end

    def match_repeats_altweekly_vague
      @components[@pos+1] == "altweekly"
    end

    def found_repeats_altweekly_vague
      @constructs << RecurrenceConstruct.new(:repeats => :altweekly, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end

    def match_repeats_monthly
      @components[@pos+1] == "monthly"
    end

    def match_repeats_daymonthly
      @components[@pos+2] && @components[@pos+3] && (@week_num = @components[@pos+2].to_i) && @week_num > 0 && @week_num <= 5 && (@day_index = ZDate.days_of_week.index(@components[@pos+3]))   # "repeats monthly 2nd wed"
    end

    def found_repeats_daymonthly
      rep_array = [[@week_num, @day_index]]     # That is NOT a typo, not sure what I meant by that! maybe the nested array
      j = 4
      while @components[@pos+j] && @components[@pos+j+1] && (@week_num = @components[@pos+j].to_i) && @week_num > 0 && @week_num <= 5 && (@day_index = ZDate.days_of_week.index(@components[@pos+j+1]))
        rep_array << [@week_num, @day_index]
        j += 2
      end
      @constructs << RecurrenceConstruct.new(:repeats => :daymonthly, :repeats_on => rep_array, :comp_start => @pos, :comp_end => @pos += (j - 1), :found_in => method_name)
    end

    def match_repeats_datemonthly
      @components[@pos+2] && @components[@pos+2].valid_dd? && @date_array = [@components[@pos+2].to_i]   # repeats monthly 22nd  
    end

    def found_repeats_datemonthly
      j = 3
      while @components[@pos+j] && @components[@pos+j].valid_dd?
        @date_array << @components[@pos+j].to_i
        j += 1
      end
      @constructs << RecurrenceConstruct.new(:repeats => :datemonthly, :repeats_on => @date_array, :comp_start => @pos, :comp_end => @pos += (j - 1), :found_in => method_name)
    end
    
    def match_repeats_altmonthly
      @components[@pos+1] == "altmonthly"
    end

    def match_repeats_altmonthly_daymonthly
      @components[@pos+2] && @components[@pos+3] && (@week_num = @components[@pos+2].to_i) && @week_num > 0 && @week_num <= 5 && (@day_index = ZDate.days_of_week.index(@components[@pos+3]))   # "repeats altmonthly 2nd wed"
    end

    def found_repeats_altmonthly_daymonthly
      rep_array = [[@week_num, @day_index]]
      j = 4
      while @components[@pos+j] && @components[@pos+j+1] && (@week_num = @components[@pos+j].to_i) && @week_num > 0 && @week_num <= 5 && (@day_index = ZDate.days_of_week.index(@components[@pos+j+1]))
        rep_array << [@week_num, @day_index]
        j += 2
      end
      @constructs << RecurrenceConstruct.new(:repeats => :altdaymonthly, :repeats_on => rep_array, :comp_start => @pos, :comp_end => @pos += (j - 1), :found_in => method_name)
    end

    def match_repeats_altmonthly_datemonthly
      @components[@pos+2] && @components[@pos+2].valid_dd? && @date_array = [@components[@pos+2].to_i]   # repeats altmonthly 22nd
    end

    def found_repeats_altmonthly_datemonthly
      j = 3
      while @components[@pos+j] && @components[@pos+j].valid_dd?
        @date_array << @components[@pos+j].to_i
        j += 1
      end
      @constructs << RecurrenceConstruct.new(:repeats => :altdatemonthly, :repeats_on => @date_array, :comp_start => @pos, :comp_end => @pos += (j - 1), :found_in => method_name)
    end
    
    def match_repeats_threemonthly
      @components[@pos+1] == "threemonthly"
    end

    def match_repeats_threemonthly_daymonthly
      @components[@pos+2] && @components[@pos+3] && (@week_num = @components[@pos+2].to_i) && @week_num > 0 && @week_num <= 5 && (@day_index = ZDate.days_of_week.index(@components[@pos+3]))   # "repeats threemonthly 2nd wed"
    end

    def found_repeats_threemonthly_daymonthly
      rep_array = [[@week_num, @day_index]]     # That is NOT a typo
      j = 4
      while @components[@pos+j] && @components[@pos+j+1] && (@week_num = @components[@pos+j].to_i) && @week_num > 0 && @week_num <= 5 && (@day_index = ZDate.days_of_week.index(@components[@pos+j+1]))
        rep_array << [@week_num, @day_index]
        j += 2
      end
      @constructs << RecurrenceConstruct.new(:repeats => :threedaymonthly, :repeats_on => rep_array, :comp_start => @pos, :comp_end => @pos += (j - 1), :found_in => method_name)
    end

    def match_repeats_threemonthly_datemonthly
      @components[@pos+2] && @components[@pos+2].valid_dd? && @date_array = [@components[@pos+2].to_i]   # repeats threemonthly 22nd
    end  

    def found_repeats_threemonthly_datemonthly
      j = 3
      while @components[@pos+j] && @components[@pos+j].valid_dd?
        @date_array << @components[@pos+j].to_i
        j += 1
      end
      @constructs << RecurrenceConstruct.new(:repeats => :threedatemonthly, :repeats_on => @date_array, :comp_start => @pos, :comp_end => @pos += (j - 1), :found_in => method_name)
    end

    def match_for_x
      @components[@pos]=="for" && @components[@pos+1].digits_only? && @length = @components[@pos+1].to_i
    end  

    def match_for_x_days
      @components[@pos+2] =~ /days?/
    end

    def found_for_x_days
      @constructs << WrapperConstruct.new(:wrapper_type => 2, :wrapper_length => @length, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_for_x_weeks
      @components[@pos+2] =~ /weeks?/
    end

    def found_for_x_weeks
      @constructs << WrapperConstruct.new(:wrapper_type => 3, :wrapper_length => @length, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_for_x_months
      @components[@pos+2] =~ /months?/
    end

    def found_for_x_months
      @constructs << WrapperConstruct.new(:wrapper_type => 4, :wrapper_length => @length, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end
    
    def match_this
      @components[@pos]=="this"
    end

    def match_this_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+1])
    end

    def found_this_dayname
      day_to_add = @curdate.this(@day_index)
      @constructs << DateConstruct.new(:date => day_to_add, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
      while @components[@pos+1] && @day_index = ZDate.days_of_week.index(@components[@pos+1])
        # note @pos gets incremented on each pass
        @constructs << DateConstruct.new(:date => day_to_add = day_to_add.this(@day_index), :comp_start => @pos + 1, :comp_end => @pos += 1, :found_in => method_name)
      end
    end

    def match_this_week
      @components[@pos+1] =~ /weeks?/
    end

    def found_this_week
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @curdate.add_days(7), :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end

    def match_this_month
      @components[@pos+1] =~ /months?/
    end

    def found_this_month
      date = NLP::use_date_correction ? @curdate : @curdate.beginning_of_month
      @constructs << DateSpanConstruct.new(:start_date => date, :end_date => @curdate.end_of_month, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end
    

    def match_next
      @components[@pos]=="next"
    end

    def match_next_weekend
      @components[@pos+1]=="weekend"   ## "next weekend"
    end

    def found_next_weekend
      dsc = DateSpanConstruct.new(:start_date => @curdate.next(5), :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
      dsc.end_date = dsc.start_date.add_days(1)
      @constructs << dsc
    end

    def match_next_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+1])  ## if "next [day]"
    end

    def found_next_dayname
      day_to_add = @curdate.next(@day_index)
      @constructs << DateConstruct.new(:date => day_to_add, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
      while @components[@pos+1] && @day_index = ZDate.days_of_week.index(@components[@pos+1])
        # note @pos gets incremented on each pass
        @constructs << DateConstruct.new(:date => day_to_add = day_to_add.this(@day_index), :comp_start => @pos + 1, :comp_end => @pos += 1, :found_in => method_name)
      end
    end

    def match_next_x
      @components[@pos+1] && @components[@pos+1].digits_only? && @length = @components[@pos+1].to_i
    end

    def match_next_x_days
      @components[@pos+2] =~ /days?/                              ## "next x days"
    end

    def found_next_x_days
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @curdate.add_days(@length), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_next_x_weeks
      @components[@pos+2] =~ /weeks?/                             ## "next x weeks"
    end

    def found_next_x_weeks
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @curdate.add_weeks(@length), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_next_x_months
      @components[@pos+2] =~ /months?/                             ## "next x months"
    end

    def found_next_x_months
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @curdate.add_months(@length), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_next_x_years
      @components[@pos+2] =~ /years?/                          ## "next x years"
    end

    def found_next_x_years
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @curdate.add_years(@length), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_next_week
      @components[@pos+1] =~ /weeks?/
    end

    def found_next_week
      sd = @curdate.add_days(7)
      ed = sd.add_days(7)
      @constructs << DateSpanConstruct.new(:start_date => sd, :end_date => ed, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end

    def match_next_month
      # note it is important that all other uses of "next month" come after indicating words such as "every day next month"; otherwise they will be converted here
      @components[@pos+1] =~ /months?/
    end

    def found_next_month
      sd = @curdate.add_months(1).beginning_of_month
      ed = sd.end_of_month
      @constructs << DateSpanConstruct.new(:start_date => sd, :end_date => ed, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end
    
    def match_week
      @components[@pos] == "week"
    end
    
    def match_week_of_date
      @components[@pos+1] == "of" && @date1 = @components[@pos+2].interpret_date(@curdate)
    end

    def found_week_of_date
      @constructs << DateSpanConstruct.new(:start_date => @date1, :end_date => @date1.add_days(7), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end
    
    def match_week_through_date
      @components[@pos+1] == "through" && @date1 = @components[@pos+2].interpret_date(@curdate)
    end

    def found_week_through_date
      @constructs << DateSpanConstruct.new(:start_date => @date1.sub_days(7), :end_date => @date1, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end
    
    def match_x_weeks_from
      @components[@pos].digits_only? && @components[@pos+1] =~ /^weeks?$/ && @components[@pos+2] == "from" && @length = @components[@pos].to_i      # if "x weeks from"
    end

    def match_x_weeks_from_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+3])   # if "x weeks from monday"
    end

    def found_x_weeks_from_dayname
      @constructs << DateConstruct.new(:date => @curdate.x_weeks_from_day(@length, @day_index), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    # Reduntant, preprocess out!
    def match_x_weeks_from_this_dayname
      @components[@pos+3] == "this" && @day_index = ZDate.days_of_week.index(@components[@pos+4])           # if "x weeks from this monday"
    end
    
    # Reduntant, preprocess out!
    def found_x_weeks_from_this_dayname
      # this is the exact some construct as found_x_weeks_from_dayname, just position and comp_end has to increment by 1 more; pretty stupid, this should be caught in preprocessing
      @constructs << DateConstruct.new(:date => @curdate.x_weeks_from_day(@length, @day_index), :comp_start => @pos, :comp_end => @pos += 4, :found_in => method_name)
    end

    def match_x_weeks_from_next_dayname
      @components[@pos+3] == "next" && @day_index = ZDate.days_of_week.index(@components[@pos+4])   # if "x weeks from next monday"
    end

    def found_x_weeks_from_next_dayname
      @constructs << DateConstruct.new(:date => @curdate.x_weeks_from_day(@length + 1, @day_index), :comp_start => @pos, :comp_end => @pos += 4, :found_in => method_name)
    end

    def match_x_weeks_from_tomorrow
      @components[@pos+3] == "tomorrow"       # if "x weeks from tomorrow"
    end

    def found_x_weeks_from_tomorrow
      @constructs << DateConstruct.new(:date => @curdate.add_days(1).add_weeks(@length), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_x_weeks_from_now
      @components[@pos+3] =~ /\b(today)|(now)\b/    # if "x weeks from today"
    end

    def found_x_weeks_from_now
      @constructs << DateConstruct.new(:date => @curdate.x_weeks_from_day(@length, @curdate.dayindex), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_x_weeks_from_yesterday
      @components[@pos+3] == "yesterday"    # "x weeks from yesterday"
    end

    def found_x_weeks_from_yesterday
      @constructs << DateConstruct.new(:date => @curdate.sub_days(1).add_weeks(@length), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end
    
    def match_x_months_from
      @components[@pos].digits_only? && @components[@pos+1] =~ /^months?$/ && @components[@pos+2] == "from" && @length = @components[@pos].to_i       # if "x months from"
    end

    def match_x_months_from_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+3])                                             # if "x months from monday"
    end

    def found_x_months_from_dayname
      @constructs << DateConstruct.new(:date => @curdate.this(@day_index).add_months(@length), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_x_months_from_this_dayname
      @components[@pos+3] == "this" && @day_index = ZDate.days_of_week.index(@components[@pos+4])            # if "x months from this monday"
    end

    def found_x_months_from_this_dayname
      @constructs << DateConstruct.new(:date => @curdate.this(@day_index).add_months(@length), :comp_start => @pos, :comp_end => @pos += 4, :found_in => method_name)
    end

    def match_x_months_from_next_dayname
      @components[@pos+3] == "next" && @day_index = ZDate.days_of_week.index(@components[@pos+4])            # if "x months from next monday"
    end

    def found_x_months_from_next_dayname
      @constructs << DateConstruct.new(:date => @curdate.next(@day_index).add_months(@length), :comp_start => @pos, :comp_end => @pos += 4, :found_in => method_name)
    end

    def match_x_months_from_tomorrow
      @components[@pos+3] == "tomorrow"       # if "x months from tomorrow"
    end

    def found_x_months_from_tomorrow
      @constructs << DateConstruct.new(:date => @curdate.add_days(1).add_months(@length), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_x_months_from_now
      @components[@pos+3] =~ /\b(today)|(now)\b/    # if "x months from today"
    end

    def found_x_months_from_now
      @constructs << DateConstruct.new(:date => @curdate.add_months(@length), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_x_months_from_yesterday
      @components[@pos+3] == "yesterday"    # "x months from yesterday"
    end

    def found_x_months_from_yesterday
      @constructs << DateConstruct.new(:date => @curdate.sub_days(1).add_months(@length), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end
    
    def match_x_days_from
      @components[@pos].digits_only? && @components[@pos+1] =~ /^days?$/ && @components[@pos+2] == "from" && @length = @components[@pos].to_i     # 3 days from    
    end

    def match_x_days_from_now
      @components[@pos+3] =~ /\b(now)|(today)\b/           # 3 days from today; 3 days from now
    end

    def found_x_days_from_now
      @constructs << DateConstruct.new(:date => @curdate.add_days(@length), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_x_days_from_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+3])    # 3 days from monday, why would someone do this?
    end

    def found_x_days_from_dayname
      @constructs << DateConstruct.new(:date => @curdate.this(@day_index).add_days(@length), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end
    
    def match_x_dayname_from
      @components[@pos].digits_only? && (@day_index = ZDate.days_of_week.index(@components[@pos+1])) && @components[@pos+2] == "from" && @length = @components[@pos].to_i    # "2 tuesdays from"
    end

    def match_x_dayname_from_now
      @components[@pos+3] =~ /\b(today)|(now)\b/     # if "2 tuesdays from now"
    end

    def found_x_dayname_from_now
      # this isn't exactly intuitive.  If someone says "two tuesday from now" and it is tuesday, they mean "in two weeks."  If it is not tuesday, they mean "next tuesday"
      d = (@days_index == @curdate.dayindex) ? @curdate.add_weeks(@length) : @curdate.x_weeks_from_day(@length - 1, @day_index)
      @constructs << DateConstruct.new(:date => d, :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_x_dayname_from_tomorrow
      @components[@pos+3] == "tomorrow"
    end

    def found_x_dayname_from_tomorrow
      # If someone says "two tuesday from tomorrow" and tomorrow is tuesday, they mean "two weeks from tomorrow."  If it is not tuesday, this person does not make sense, but we can interpet it as "next tuesday"
      tomorrow_index = (@curdate.dayindex + 1) % 7
      d = (@days_index == tomorrow_index) ? @curdate.add_days(1).add_weeks(@length) : @curdate.x_weeks_from_day(@length - 1, @day_index)
      @constructs << DateConstruct.new(:date => d, :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_x_dayname_from_yesterday
      @components[@pos+3] == "yesterday"
    end

    def found_x_dayname_from_yesterday
      # If someone says "two tuesday from yesterday" and yesterday was tuesday, they mean "two weeks from yesterday."  If it is not tuesday, this person does not make sense, but we can interpet it as "next tuesday"
      yesterday_index = (@curdate.dayindex == 0 ? 6 : @curdate.dayindex - 1)
      d = (@days_index == yesterday_index) ? @curdate.sub_days(1).add_weeks(@length) : @curdate.x_weeks_from_day(@length - 1, @day_index)
      @constructs << DateConstruct.new(:date => d, :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_x_dayname_from_this
      @components[@pos+3] == "this"    #  "two tuesdays from this"
    end

    def found_x_dayname_from_this
      dc = DateConstruct.new(:date => @curdate.this(@day_index).add_weeks(@length), :comp_start => @pos, :found_in => method_name)
      if @components[@post+4] == "one" || ZDate.days_of_week.index(@components[@pos+4])    # talk about redundant (2 tuesdays from this one, 2 tuesdays from this tuesday)
        dc.comp_end = @pos += 4
      else
        dc.comp_end = @pos += 3
      end
      @constructs << dc
    end

    def match_x_dayname_from_next
      @components[@pos+3] == "next"    #  "two tuesdays from next"
    end

    def found_x_dayname_from_next
      dc = DateConstruct.new(:date => @curdate.next(@day_index).add_weeks(@length), :comp_start => @pos, :found_in => method_name)
      if @components[@post+4] == "one" || ZDate.days_of_week.index(@components[@pos+4])    # talk about redundant (2 tuesdays from next one, 2 tuesdays from next tuesday)
        dc.comp_end = @pos += 4
      else
        dc.comp_end = @pos += 3
      end
      @constructs << dc
    end
    
    def match_x_minutes_from_now
      @components[@pos].digits_only? && @components[@pos+1] =~ /minutes?/ && @components[@pos+2] == "from" && @components[@pos+3] =~ /^(today|now)$/ && @length = @components[@pos].to_i
    end

    def found_x_minutes_from_now
      date = nil  # define out of scope of block
      time = @curtime.add_minutes(@length) {|days_to_increment| date = @curdate.add_days(days_to_increment)}
      @constructs << DateConstruct.new(:date => date, :comp_start => @pos, :comp_end => @pos + 4, :found_in => method_name)
      @constructs << TimeConstruct.new(:time => time, :comp_start => @pos, :comp_end => @pos += 4, :found_in => method_name)
    end

    def match_x_hours_from_now
      @components[@pos].digits_only? && @components[@pos+1] =~ /hours?/ && @components[@pos+2] == "from" && @components[@pos+3] =~ /^(today|now)$/ && @length = @components[@pos].to_i
    end

    def found_x_hours_from_now
      date = nil
      time = @curtime.add_hours(@length) {|days_to_increment| date = @curdate.add_days(days_to_increment)}
      @constructs << DateConstruct.new(:date => date, :comp_start => @pos, :comp_end => @pos + 4, :found_in => method_name)
      @constructs << TimeConstruct.new(:time => time, :comp_start => @pos, :comp_end => @pos += 4, :found_in => method_name)
    end
    
    def match_ordinal_dayname
      @components[@pos]=~/(1st|2nd|3rd|4th|5th)/ && (@day_index = ZDate.days_of_week.index(@components[@pos+1])) && @week_num = @components[@pos].to_i     # last saturday
    end

    def match_ordinal_dayname_this_month
      @components[@pos+2] == "this" && @components[@pos+3] == "month"                  # last saturday this month
    end

    def found_ordinal_dayname_this_month
      @constructs << DateConstruct.new(:date => @curdate.ordinal_dayindex(@week_num, @day_index), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_ordinal_dayname_next_month
      @components[@pos+2] == "next" && @components[@pos+3] == "month"        # 1st monday next month
    end

    def found_ordinal_dayname_next_month
      @constructs << DateConstruct.new(:date => @curdate.add_months(1).ordinal_dayindex(@week_num, @day_index), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_ordinal_dayname_monthname
      @month_index = ZDate.months_of_year.index(@components[@pos+2])         # second friday december
    end

    def found_ordinal_dayname_monthname
      @constructs << DateConstruct.new(:date => @curdate.jump_to_month(@month_index + 1).ordinal_dayindex(@week_num, @day_index), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end
    

    def match_ordinal_this_month
      @components[@pos]=~/(0?[1-9]|[12][0-9]|3[01])(st|nd|rd|th)/ && @components[@pos+1] == 'this' && @components[@pos+2] = 'month' && @length = @components[@pos].to_i      # 28th this month
    end

    def match_ordinal_next_month
      @components[@pos]=~/(0?[1-9]|[12][0-9]|3[01])(st|nd|rd|th)/ && @components[@pos+1] == 'next' && @components[@pos+2] = 'month' && @length = @components[@pos].to_i      # 28th next month
    end

    def found_ordinal_this_month
      if NLP::use_date_correction && @curdate.day > @length
        # e.g. it is the 30th of the month and a user types "1st of the month", they mean "first of next month"
        date = @curdate.add_months(1).beginning_of_month.add_days(@length - 1)
      else
        date = @curdate.beginning_of_month.add_days(@length - 1)
      end
      @constructs << DateConstruct.new(:date => date, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def found_ordinal_next_month
      @constructs << DateConstruct.new(:date => @curdate.add_months(1).beginning_of_month.add_days(@length - 1), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end
    
    
    def match_first_day
      @components[@pos] == "1st" && @components[@pos+1] == "day"     # 1st day
    end

    def match_first_day_this_month
      @components[@pos+2] == "this" && @components[@pos+3] == "month"                  # 1st day this month
    end

    def found_first_day_this_month
      @constructs << DateConstruct.new(:date => @curdate.beginning_of_month, :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_first_day_next_month
      @components[@pos+2] == "next" && @components[@pos+3] == "month"        # 1st day next month
    end

    def found_first_day_next_month
      @constructs << DateConstruct.new(:date => @curdate.add_months(1).beginning_of_month, :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_first_day_monthname
      @month_index = ZDate.months_of_year.index(@components[@pos+2])         # 1st day december
    end

    def found_first_day_monthname
      @constructs << DateConstruct.new(:date => @curdate.jump_to_month(@month_index + 1), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_last_day
      @components[@pos] == "last" && @components[@pos+1] == "day"     # last day
    end

    def match_last_day_this_month
      @components[@pos+2] == "this" && @components[@pos+3] == "month"                  # 1st day this month
    end

    def found_last_day_this_month
      @constructs << DateConstruct.new(:date => @curdate.end_of_month, :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_last_day_next_month
      @components[@pos+2] == "next" && @components[@pos+3] == "month"        # 1st day next month
    end

    def found_last_day_next_month
      @constructs << DateConstruct.new(:date => @curdate.add_months(1).end_of_month, :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_last_day_monthname
      @month_index = ZDate.months_of_year.index(@components[@pos+2])         # 1st day december
    end

    def found_last_day_monthname
      @constructs << DateConstruct.new(:date => @curdate.jump_to_month(@month_index + 1).end_of_month, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end
    
    def match_at
      @components[@pos]=="at"
    end

    def match_at_time
      @components[@pos+1] && @time1 = @components[@pos+1].interpret_time
    end

    def match_at_time_through_time
      @components[@pos+2] =~ /^(to|until|through)$/ && @components[@pos+3] && @time2 = @components[@pos+3].interpret_time
    end

    def found_at_time_through_time
      @constructs << TimeSpanConstruct.new(:start_time => @time1, :end_time => @time2, :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def found_at_time
      @constructs << TimeConstruct.new(:time => @time1, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end

    def match_all_day
      @components[@pos]=="all" && @components[@pos+1]=="day"      # all day
    end

    def found_all_day
      @constructs << TimeConstruct.new(:time => nil, :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end
    
    def match_tomorrow
      @components[@pos]=="tomorrow"
    end

    def match_tomorrow_through
      @components[@pos+1]=="until" || @components[@pos+1] == "to" || @components[@pos+1] == "through"    # "tomorrow through"
    end

    def match_tomorrow_through_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+2])       # tomorrow through thursday
    end

    def found_tomorrow_through_dayname
      @constructs << DateSpanConstruct.new(:start_date => @curdate.add_days(1), :end_date => @curdate.add_days(1).this(@day_index), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_tomorrow_through_date
      @date1 = @components[@pos+2].interpret_date(@curdate)       # tomorrow until 9/21
    end

    def found_tomorrow_through_date
      @constructs << DateSpanConstruct.new(:start_date => @curdate.add_days(1), :end_date => @date1, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def found_tomorrow
      @constructs << DateConstruct.new(:date => @curdate.add_days(1), :comp_start => @pos, :comp_end => @pos, :found_in => method_name)
    end
    
    def match_now
      @components[@pos]=="today" || @components[@pos]=="now"
    end

    def match_now_through
      @components[@pos+1]=="until" || @components[@pos+1] == "to" || @components[@pos+1] == "through"   # "today through"
    end

    def match_now_through_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos+2])     # today through thursday
    end

    def found_now_through_dayname
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @curdate.this(@day_index), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    # redundant!! preprocess this out of here!
    def match_now_through_following_dayname
      @components[@pos+2] =~ /following|this/ && @day_index = ZDate.days_of_week.index(@components[@pos+3])    # today through following friday
    end

    # redundant!! preprocess this out of here!
    def found_now_through_following_dayname
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @curdate.this(@day_index), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def match_now_through_date
      @date1 = @components[@pos+2].interpret_date(@curdate)       # now until 9/21
    end

    def found_now_through_date
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @date1, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_now_through_tomorrow
      @components[@pos+2]=="tomorrow"
    end

    def found_now_through_tomorrow
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @curdate.add_days(1), :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def match_now_through_next_dayname
      @components[@pos+2] == "next" && @day_index = ZDate.days_of_week.index(@components[@pos+3])     # Today through next friday
    end

    def found_now_through_next_dayname
      @constructs << DateSpanConstruct.new(:start_date => @curdate, :end_date => @curdate.next(@day_index), :comp_start => @pos, :comp_end => @pos += 3, :found_in => method_name)
    end

    def found_now
      @constructs << DateConstruct.new(:date => @curdate, :comp_start => @pos, :comp_end => @pos, :found_in => method_name)
    end
    
    def match_dayname
      @day_index = ZDate.days_of_week.index(@components[@pos])
    end

    def match_dayname_the_ordinal
      @components[@pos+1] == "the" && @date1 = @components[@pos+2].interpret_date(@curdate)    # if "tue the 23rd"
    end

    def found_dayname_the_ordinal
      # user may have specified "monday the 2nd" while in the previous month, so first check if dayname matches date.dayname, if it doesn't increment by a month and check again
      if @date1.dayname == @components[@pos] || ((tmp = @date1.add_months(1)) && tmp.dayname == @components[@pos] && @date1 = tmp)
        @constructs << DateConstruct.new(:date => @date1, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
      end
    end

    def match_dayname_x_weeks_from_this
      @components[@pos+1] && @components[@pos+1].digits_only? && @components[@pos+2] =~ /\bweeks?\b/ && @components[@pos+3] =~ /\b(from)|(after)/ && @components[@pos+4] == "this" && @length = @components[@pos+1]           # "monday two weeks from this
    end

    def found_dayname_x_weeks_from_this
      dc = DateConstruct.new(:date => @curdate.this(@dayindex).add_weeks(@length), :comp_start => @pos, :found_in => method_name)
      if ZDate.days_of_week.include?(@components[@pos+5])  #redundant
        dc.comp_end = @pos += 5 
      else
        dc.comp_end = @pos += 4
      end
      @constructs << dc
    end

    def match_dayname_x_weeks_from_next
      @components[@pos+1] && @components[@pos+1].digits_only? && @components[@pos+2] =~ /\bweeks?\b/ && @components[@pos+3] =~ /\b(from)|(after)/ && @components[@pos+4] == "next" && @length = @components[@pos+1]           # "monday two weeks from this
    end

    def found_dayname_x_weeks_from_next
      dc = DateConstruct.new(:date => @curdate.next(@dayindex).add_weeks(@length), :comp_start => @pos, :found_in => method_name)
      if ZDate.days_of_week.include?(@components[@pos+5])  #redundant
        dc.comp_end = @pos += 5 
      else
        dc.comp_end = @pos += 4
      end
      @constructs << h
    end

    # redundant, same as found_this_dayname
    def found_dayname
      day_to_add = @curdate.this(@day_index)
      @constructs << DateConstruct.new(:date => day_to_add, :comp_start => @pos, :comp_end => @pos, :found_in => method_name)
      while @components[@pos+1] && @day_index = ZDate.days_of_week.index(@components[@pos+1])
        # note @pos gets incremented here:
        @constructs << DateConstruct.new(:date => day_to_add = day_to_add.this(@day_index), :comp_start => @pos + 1, :comp_end => @pos += 1, :found_in => method_name)
      end
    end

    def match_through_monthname
      @components[@pos] == "through" && @month_index = ZDate.months_of_year.index(@components[@pos+1])
    end

    def found_through_monthname
      # this is really a wrapper, we don't know when the start date is, so make sure @constructs gets wrapper first, as date constructs always have to appear after wrapper
      @constructs << WrapperConstruct.new(:wrapper_type => 1, :comp_start => @pos, :comp_end => @pos + 1, :found_in => method_name)
      @constructs << DateConstruct.new(:date => @curdate.jump_to_month(@month_index + 1).sub_days(1), :comp_start => @pos, :comp_end => @pos += 1, :found_in => method_name)
    end

    def match_monthname
      # note it is important that all other uses of monthname come after indicating words such as "the third day of december"; otherwise they will be converted here
      @month_index = ZDate.months_of_year.index(@components[@pos])
    end

    def found_monthname
      sd = @curdate.jump_to_month(@month_index + 1)
      ed = sd.end_of_month
      @constructs << DateSpanConstruct.new(:start_date => sd, :end_date => ed, :comp_start => @pos, :comp_end => @pos, :found_in => method_name)
    end


    def match_start
      @components[@pos] == "start"
    end

    def found_start
      #wrapper_type 0 is a start wrapper
      @constructs << WrapperConstruct.new(:wrapper_type => 0, :comp_start => @pos, :comp_end => @pos, :found_in => method_name)
    end

    def match_through
      @components[@pos] == "through"
    end

    def found_through
      #wrapper_type 1 is an end wrapper
      @constructs << WrapperConstruct.new(:wrapper_type => 1, :comp_start => @pos, :comp_end => @pos, :found_in => method_name)
    end

    def match_time
      @time1 = @components[@pos].interpret_time
    end

    def match_time_through_time
      @components[@pos+1] =~ /^(to|through)$/ && @time2 = @components[@pos+2].interpret_time
    end

    def found_time_through_time
      @constructs << TimeSpanConstruct.new(:start_time => @time1, :end_time => @time2, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def found_time
      @constructs << TimeConstruct.new(:time => @time1, :comp_start => @pos, :comp_end => @pos, :found_in => method_name)
      match = true
    end

    def match_date
      @date1 = @components[@pos].interpret_date(@curdate)
    end

    def match_date_through_date
      @components[@pos+1] =~ /^(through|to|until)$/ && @date2 = @components[@pos+2].interpret_date(@curdate)
    end

    def found_date_through_date
      @constructs << DateSpanConstruct.new(:start_date => @date1, :end_date => @date2, :comp_start => @pos, :comp_end => @pos += 2, :found_in => method_name)
    end

    def found_date
      @constructs << DateConstruct.new(:date => @date1, :comp_start => @pos, :comp_end => @pos, :found_in => method_name)
    end
  end # END class ConstructFinder
end

