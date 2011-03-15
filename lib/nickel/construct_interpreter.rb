# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module Nickel

  class ConstructInterpreter

    attr_reader :occurrences, :constructs, :curdate

    def initialize(constructs, curdate)
      @constructs = constructs
      @curdate = curdate
      @occurrences = []             # output
      initialize_index_to_type_map
      initialize_user_input_style
      initialize_arrays_of_construct_indices
      initialize_sorted_time_map
      finalize_constructs
    end

    def run
      if found_dates
        occurrences_from_dates
      elsif found_one_date_span
        occurrences_from_one_date_span
      elsif found_recurrences_and_optional_date_span
        occurrences_from_recurrences_and_optional_date_span
      elsif found_wrappers_only
        occurrences_from_wrappers_only
      end
    end
    
    private
    def initialize_index_to_type_map
      # The @index_to_type_map hash looks like this: {0 => :date, 1 => :timespan, ...}
      # Each key represents the index in @constructs and the value represents that constructs class.
      @index_to_type_map = {}
      @constructs.each_with_index do |c,i|
        @index_to_type_map[i] = case c.class.name
    	  	when "Nickel::DateConstruct"         then :date
    	  	when "Nickel::TimeConstruct"         then :time
    	  	when "Nickel::DateSpanConstruct"     then :datespan
    	  	when "Nickel::TimeSpanConstruct"     then :timespan
    	  	when "Nickel::RecurrenceConstruct"   then :recurrence
    	  	when "Nickel::WrapperConstruct"      then :wrapper
    	  end
      end
    end
    
    def initialize_user_input_style
      # Initializes @user_input_style.
  	  # Determine user input style, i.e. "DATE TIME DATE TIME"  OR "TIME DATE TIME DATE".
  	  # Determine user input style, i.e. "DATE TIME DATE TIME"  OR "TIME DATE TIME DATE".
  	  case (@index_to_type_map[0] == :wrapper ? @index_to_type_map[1] : @index_to_type_map[0])
  	  	when :date        then @user_input_style = :datetime
  	  	when :time        then @user_input_style = :timedate
  	  	when :datespan    then @user_input_style = :datetime
  	  	when :timespan    then @user_input_style = :timedate
  	  	when :recurrence  then @user_input_style = :datetime
  	    else
  	      # We only have wrappers. It doesn't matter which user style we choose.
  	      @user_input_style = :datetime   
  	    end
    end
    
    def initialize_arrays_of_construct_indices
      @dci,@tci,@dsci,@tsci,@rci,@wci = [],[],[],[],[],[]
      @index_to_type_map.each do |i, type|
        case type
          when :date        then @dci  << i
          when :time        then @tci  << i
          when :datespan    then @dsci << i
          when :timespan    then @tsci << i
          when :recurrence  then @rci  << i
          when :wrapper     then @wci  << i
        end
      end
    end
    
    def initialize_sorted_time_map
      # Sorted time map has date/datespan/recurrence construct indices as keys, and
      # an array of time/timespan indices as values.
      @sorted_time_map = {}                       
      
      # Get all indices of date/datespan/recurrence constructs in the order they occurred.
      date_indices = (@dci + @dsci + @rci).sort 
      
      # What is inhert_on about? If a user enters something like "wed and fri at 4pm" they
      # really want 4pm to be associated with wed and fri.  For all dates that we don't find
      # associated times, we append the dates index to the inherit_on array. Then, once we 
      # find a date associated with times, we copy the sorted_time_map at that index to the
      # other indices in the inherit_on array.
      #
      # If @user_input_style is :datetime, then inherit_on will hold date indices that must inherit
      # from the next date with associated times.  If @user_input_style is :timedate, then
      # inherit_from will hold the last date index with associated times, and subsequent dates that
      # do not have associated times will inherit from this index.
      @user_input_style == :datetime ? inherit_on = [] : inherit_from = nil
      
      # Iterate date_indices and populate @sorted_time_map
      date_indices.each do |i|
        # Do not change i.
        j = i   

        # Now find all time and time span construct indices between this index and a boundary.
        # Boundaries are any other index in date_indices, -1 (passed the first construct), 
        # and @constructs.size (passed the last construct).
        map_to_indices = []
        while (j = move_time_map_index(j)) && j != -1 && j != @constructs.size && !date_indices.include?(j)  # boundaries
          (index_references_time(j) || index_references_timespan(j)) && map_to_indices << j
        end
        
        # NOTE: time/timespan indices are sorted by the order which they appeared, e.g.
        # their construct index number.
        @sorted_time_map[i] = map_to_indices.sort      
        if @user_input_style == :datetime 
          inherit_on = handle_datetime_time_map_inheritance(inherit_on, i)
        else
          inherit_from = handle_timedate_time_map_inheritance(inherit_from, i)
        end
      end
    end
    
    def move_time_map_index(index)
      # The time map index must be moved based on user input style.  For instance, 
      # if a user enters dates then times, we must attach times to preceding dates, 
      # meaning move forward.
      if @user_input_style == :datetime     then index + 1
      elsif @user_input_style == :timedate  then index - 1
      else raise "ConstructInterpreter#move_time_map_index says: @user_input_style is not valid"
      end
    end
  
    def handle_datetime_time_map_inheritance(inherit_on, date_index)
      if @sorted_time_map[date_index].empty?  
        # There are no times for this date, mark to be inherited
        inherit_on << date_index
      else
        # There are times for this date, use them for any indices marked as inherit_on.
        # Then clear the inherit_on array.
        inherit_on.each {|k| @sorted_time_map[k] = @sorted_time_map[date_index]}
        inherit_on = []
      end
      inherit_on
    end

    def handle_timedate_time_map_inheritance(inherit_from, date_index)
      if @sorted_time_map[date_index].empty?
        # There are no times for this date, try inheriting from last batch of times.
        @sorted_time_map[date_index] = @sorted_time_map[inherit_from]  if inherit_from
      else
        inherit_from = date_index
      end
      inherit_from
    end
    
    def index_references_time(index)
      @index_to_type_map[index] == :time
    end

    def index_references_timespan(index)
      @index_to_type_map[index] == :timespan
    end
      
    # Returns either @time or @start_time, depending on whether tindex references a Time or TimeSpan construct
    def start_time_from_tindex(tindex)
      if index_references_time(tindex)
        return @constructs[tindex].time
      elsif index_references_timespan(tindex)
        return @constructs[tindex].start_time
      else 
        raise "ConstructInterpreter#start_time_from_tindex says: tindex does not reference a time or time span"
      end
    end
    
    # If guess is false, either start time or end time (but not both) must already be firm.
    # The time that is not firm will be modified according to the firm time and set to firm.
    def finalize_timespan_constructs(guess = false)
      @tsci.each do |i|
        st, et = @constructs[i].start_time, @constructs[i].end_time
        if st.firm && et.firm
          next  # nothing to do if start and end times are both firm
        elsif !st.firm && et.firm
          st.modify_such_that_is_before(et)
        elsif st.firm && !et.firm
          et.modify_such_that_is_after(st)
        else
          et.guess_modify_such_that_is_after(st)  if guess
        end
      end
    end
    
    # One of this methods functions will be to assign proper am/pm values to time
    # and timespan constructs if they were not specified.
    def finalize_constructs
      
      # First assign am/pm values to timespan constructs independent of 
      # other times in timemap.
      finalize_timespan_constructs
      
      # Next we need to burn through the time map, find any start times 
      # that are not firm, and set them based on previous firm times.
      # Note that @sorted_time_map has the format {date_index => [array, of, time, indices]}
      @sorted_time_map.each_value do |time_indices|
        # The time_indices array holds TimeConstruct and TimeSpanConstruct indices.
        # The time_array will hold an array of ZTime objects to modify (potentially)
        time_array = []   
        time_indices.each {|tindex| time_array << start_time_from_tindex(tindex)}
        ZTime.am_pm_modifier(*time_array)
      end
      
      # Finally, we need to modify the timespans based on the the time info from am_pm_modifier.
      # We also need to guess at any timespans that didn't get any help from am_pm_modifier.
      # i.e. we originally guessed at timespans independently of other time info in time map;
      # now that we have modified start times based on other info in time map, we can refine the
      # end times in our time spans.  If we didn't pick them up before.
      finalize_timespan_constructs(true)
    end
    
    # The @sorted_time_map hash has keys of date/datespans/recurrence indices (in this case date),
    # and an array of time and time span indices as values.  This checks to make sure that array of 
    # times is not empty, and if it is there are no times associated with this date construct.
    # Huh? That does not explain this method... at all.
    def create_occurrence_for_each_time_in_time_map(occ_base, dindex, &block)
      if !@sorted_time_map[dindex].empty?           
        @sorted_time_map[dindex].each do |tindex|   # tindex may be time index or time span index
          occ = occ_base.dup
          occ.start_time = start_time_from_tindex(tindex)
          if index_references_time(tindex)
            occ.start_time = @constructs[tindex].time
          elsif index_references_timespan(tindex)
            occ.start_time = @constructs[tindex].start_time
            occ.end_time = @constructs[tindex].end_time
          end
          yield(occ)
        end
      else
        yield(occ_base)
      end
    end

    def found_dates
      # One or more date constructs, NO date spans, NO recurrence,
      # possible wrappers, possible time constructs, possible time spans
      @dci.size > 0 && @dsci.size == 0 && @rci.size == 0
    end

    def occurrences_from_dates
      @dci.each do |dindex|
        occ_base = Occurrence.new(:type => :single, :start_date => @constructs[dindex].date)
        create_occurrence_for_each_time_in_time_map(occ_base, dindex) {|occ| @occurrences << occ}
      end
    end
  
    def found_one_date_span
      @dci.size == 0 && @dsci.size == 1 && @rci.size == 0
    end

    def occurrences_from_one_date_span
      occ_base = Occurrence.new(:type => :daily,
                                :start_date => @constructs[@dsci[0]].start_date,
                                :end_date => @constructs[@dsci[0]].end_date,
                                :interval => 1)
      create_occurrence_for_each_time_in_time_map(occ_base, @dsci[0]) {|occ| @occurrences << occ}
    end
    
    def found_recurrences_and_optional_date_span
      @dsci.size <= 1 && @rci.size >= 1   # dates are optional
    end

    def occurrences_from_recurrences_and_optional_date_span
      if @dsci.size == 1  
        # If a date span exists, it functions as wrapper.
        occ_base_opts = {:start_date => @constructs[@dsci[0]].start_date, :end_date => @constructs[@dsci[0]].end_date}
      else  
        # Perhaps there are type 0 or type 1 wrappers to provide start/end dates.
        occ_base_opts = occ_base_opts_from_wrappers
      end
      
      @rci.each do |rcindex|
        # Construct#interpret returns an array of hashes, each hash represents a single occurrence.
        @constructs[rcindex].interpret.each do |rec_occ_base_opts|    
          # RecurrenceConstruct#interpret returns base_opts for each occurrence,
          # but they must be merged with start/end dates, if supplied.
          occ_base = Occurrence.new(rec_occ_base_opts.merge(occ_base_opts))   
          # Attach times:
          create_occurrence_for_each_time_in_time_map(occ_base, rcindex) {|occ| @occurrences << occ}
        end
      end
    end
    
    def found_wrappers_only
      # This should really be "found length wrappers only", because @dci.size must be zero, 
      # and start/end wrappers require a date.
      @dsci.size == 0 && @rci.size == 0 && @wci.size > 0 && @dci.size == 0
    end

    def occurrences_from_wrappers_only
      occ_base = {:type => :daily, :interval => 1}
      @occurrences << Occurrence.new(occ_base.merge(occ_base_opts_from_wrappers))
    end

    def occ_base_opts_from_wrappers
      base_opts = {}
      # Must do type 0 and 1 wrappers first, imagine something like 
      # "every friday starting next friday for 6 months".
      @wci.each do |wi|
        # Make sure the construct after the wrapper is a date.
        if @constructs[wi].wrapper_type == 0 && @dci.include?(wi + 1)  
          base_opts[:start_date] = @constructs[wi + 1].date
        elsif @constructs[wi].wrapper_type == 1 && @dci.include?(wi + 1)
          base_opts[:end_date] = @constructs[wi + 1].date
        end
      end
      
      # Now pick up wrapper types 2,3,4
      @wci.each do |wi|
        if @constructs[wi].wrapper_type >= 2
          if base_opts[:start_date].nil? && base_opts[:end_date].nil?   # span must start today
            base_opts[:start_date] = @curdate.dup   
            base_opts[:end_date] = case @constructs[wi].wrapper_type
              when 2 then @curdate.add_days(@constructs[wi].wrapper_length)
              when 3 then @curdate.add_weeks(@constructs[wi].wrapper_length)
              when 4 then @curdate.add_months(@constructs[wi].wrapper_length)
            end
          elsif base_opts[:start_date] && base_opts[:end_date].nil?
            base_opts[:end_date] = case @constructs[wi].wrapper_type
              when 2 then base_opts[:start_date].add_days(@constructs[wi].wrapper_length)
              when 3 then base_opts[:start_date].add_weeks(@constructs[wi].wrapper_length)
              when 4 then base_opts[:start_date].add_months(@constructs[wi].wrapper_length)
            end
          elsif base_opts[:start_date].nil? && base_opts[:end_date]    # for 6 months until jan 3rd
            base_opts[:start_date] = case @constructs[wi].wrapper_type
              when 2 then base_opts[:end_date].sub_days(@constructs[wi].wrapper_length)
              when 3 then base_opts[:end_date].sub_weeks(@constructs[wi].wrapper_length)
              when 4 then base_opts[:end_date].sub_months(@constructs[wi].wrapper_length)
            end
          end
        end
      end
      base_opts
    end
  end
end
