# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module Nickel

  class NLP

    attr_reader :query, :input_date, :input_time, :nlp_query
    attr_reader :construct_finder, :construct_interpreter
    attr_reader :occurrences, :output
    
    # Never, EVER change the default behavior to false;  <-- then why did I put it here? 
    @use_date_correction = true  
    class << self; attr_accessor :use_date_correction; end

    def initialize(query, date_time = Time.now)  
      raise InvalidDateTimeError unless [DateTime, Time].include?(date_time.class)
      str_time = date_time.strftime("%Y%m%dT%H%M%S")
      validate_input query, str_time
      @query = query.dup
      @input_date = ZDate.new str_time[0..7]   # up to T, note format is already verified
      @input_time = ZTime.new str_time[9..14]  # after T
      #setup_logger
    end

    def parse
      @nlp_query = NLPQuery.new(@query).standardize   # standardizes the query
      @construct_finder = ConstructFinder.new(@nlp_query, @input_date, @input_time)
      @construct_finder.run
      @nlp_query.extract_message(@construct_finder.constructs)
      @construct_interpreter = ConstructInterpreter.new(@construct_finder.constructs, @input_date)  # input_date only needed for wrappers
      @construct_interpreter.run
      @occurrences = Occurrence.finalizer(@construct_interpreter.occurrences, @input_date)   # finds start and end dates
      @occurrences.sort! {|x,y| if x.start_date > y.start_date then 1 elsif x.start_date < y.start_date then -1 else 0 end}    # sorts occurrences by start date
      @output = @occurrences # legacy
      @occurrences
    end
    
    def setup_logger
      @logger = Logger.new(STDOUT)
      def @logger.blue(a)
        self.warn "\e[44m #{a.inspect} \e[0m"
      end
    end
    
    def inspect
      "message: \"#{message}\", occurrences: #{occurrences.inspect}"
    end

    # Pass :inspect or :pretty_inspect as the inspect_method
    def debug_str(inspect_method = :inspect)
      "Current Date: #{self.input_date.readable}\nCurrent Time: #{self.input_time.readable}\n\nQuery: #{self.query}\nStandardized Query: #{self.nlp_query}\nQuery changed in: #{self.nlp_query.changed_in.inspect}\n\nConstructs Found: #{s = "\n"; self.construct_finder.constructs.each{|x| s << x.send(inspect_method) + "\n"}; s}\n\n@construct_interpreter: #{self.construct_interpreter.send(inspect_method)}"
    end
    
    def message
      @nlp_query.message
    end
    
    private
    def validate_input query, date_time
      raise "Empty NLP query" unless query.length > 0
      raise "NLP says: date_time is not in the correct format" unless date_time =~ /^\d{8}T\d{6}$/
    end
  end

  class InvalidDateTimeError < StandardError
    def message
      "You must pass in a ruby DateTime or Time class object"
    end
   end
end

