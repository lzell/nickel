# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module Nickel

  class NLPQuery < String
    include NLPQueryConstants
    
    # Note there is no initialize here, it is inherited from string class.
    attr_reader :after_formatting, :changed_in, :message
    
    def standardize
      @query = self.dup # needed for case correcting after extract_message has been called
      query_formatting  # easy text manipulation, no regex involved here
      query_pre_processing  # puts query in the form that construct_finder understands, lots of manipulation here
      self
    end

    def query_formatting
      gsub!(/\n/,'')
      downcase!
      remove_unused_punctuation
      replace_backslashes
      run_spell_check
      remove_unnecessary_words
      standardize_days
      standardize_months
      standardize_numbers
      standardize_am_pm
      replace_hyphens
      insert_repeats_before_words_indicating_recurrence_lame
      insert_space_at_end_of_string_lame
      @after_formatting = self.dup    # save current state
    end
  
    # Usage: 
    #   self.nsub!(/foo/, 'bar')
    #
    # nsub! is like gsub! except it logs the calling method in @changed_in.
    # There is another difference: When using blocks, matched strings are 
    # available as block params, e.g.: # nsub!(/(match1)(match2)/) {|m1,m2|}
    #
    # I wrote this because I was having problems overriding gsub and passing
    # a block from the new gsub to super.
    def nsub!(*args)
      if m = self.match(args[0])    # m will now hold the FIRST set of backreferenced matches
        # there is at least one match
        @changed_in ||= []
        @changed_in << calling_method
        if block_given?
          # gsub!(args[0]) {yield(*m.to_a[1..-1])}    # There is a bug here: If gsub matches more than once, 
                                                      # then the first set of referenced matches will be passed to the block
          ret_str = m.pre_match + m[0].sub(args[0]) {yield(*m.to_a[1..-1])}   # this will take care of the first set of matches
          while (m_old = m.dup) && (m = m.post_match.match(args[0]))
            ret_str << m.pre_match + m[0].sub(args[0]) {yield(*m.to_a[1..-1])}
          end
          ret_str << m_old.post_match
          self.sub!(/.*/,ret_str)
        else
          gsub!(args[0],args[1])
        end
      end
    end

    def query_pre_processing
      standardize_input
    end

    def remove_unused_punctuation
      nsub!(/,/,' ')
      nsub!(/\./,'')
      nsub!(/;/,'')
      nsub!(/['`]/,'')
    end

    def replace_backslashes
      nsub!(/\\/,'/')
    end

    def run_spell_check
      nsub!(/tomm?orr?ow|romorrow/,'tomorrow')
      nsub!(/weeknd/,'weekend')
      nsub!(/weekends/,'every sat sun')
      nsub!(/everyother/,'every other')
      nsub!(/weak/,'week')
      nsub!(/everyweek/,'every week')
      nsub!(/everymonth/,'every month')
      nsub!(/c?h[oa]nn?[aui][ck][ck]?[ua]h?/,'hannukkah')
      nsub!(/frist/,'1st')
      nsub!(/eveyr|evrey/,'every')
      nsub!(/fridya|friady|fridy/,'friday')
      nsub!(/thurdsday/,'thursday')
      nsub!(/x-?mas/,'christmas')
      nsub!(/st\s+(patrick|patty|pat)s?(\s+day)?/,'st patricks day')
      nsub!(/frouth/,'fourth')
      nsub!(/\btill\b/,'through')
      nsub!(/\bthru\b|\bthrouh\b|\bthough\b|\bthrew\b|\bthrow\b|\bthroug\b|\bthuogh\b/,'through')
      nsub!(/weekdays|every\s+weekday/,'every monday through friday')
      nsub!(/\bevery?day\b/,'every day')
      nsub!(/eigth/,'eighth')
      nsub!(/bi[-\s]monthly/,'bimonthly')
      nsub!(/tri[-\s]monthly/,'trimonthly')
    end

    def remove_unnecessary_words
      nsub!(/coming/,'')
      nsub!(/o'?clock/,'')
      nsub!(/\btom\b/,'tomorrow')
      nsub!(/\s*in\s+(the\s+)?(morning|am)/,' am')
      nsub!(/\s*in\s+(the\s+)?(afternoon|pm|evenn?ing)/,' pm')
      nsub!(/\s*at\s+night/,'pm')
      nsub!(/(after\s*)?noon(ish)?/,'12:00pm')
      nsub!(/\bmi(dn|nd)ight\b/,'12:00am')
      nsub!(/final/,'last') 
      nsub!(/recur(s|r?ing)?/,'repeats')
      nsub!(/\beach\b/,'every')
      nsub!(/running\s+(until|through)/,'through')
      nsub!(/runn?(s|ing)|go(ing|e?s)/,'for')
      nsub!(/next\s+occ?urr?[ae]nce(\s+is)?/,'start')
      nsub!(/next\s+date(\s+it)?(\s+occ?urr?s)?(\s+is)?/,'start')
      nsub!(/forever/,'repeats daily')
      nsub!(/\bany(?:\s*)day\b/,'every day')
      nsub!(/^anytime$/,'every day')  # user entered anytime by itself, not 'dayname anytime', caught next
      nsub!(/any(\s)?time|whenever/,'all day')
    end

    def standardize_days
      nsub!(/mondays/,'every mon')
      nsub!(/monday/,'mon')
      nsub!(/tuesdays/,'every tue')
      nsub!(/tuesadys/,'every tue')
      nsub!(/tuesday/,'tue')
      nsub!(/tuesady/,'tue')
      nsub!(/wednesdays/,'every wed')
      nsub!(/wednesday/,'wed')
      nsub!(/thursdays/,'every thu')
      nsub!(/thurdsays/,'every thu')
      nsub!(/thursadys/,'every thu')
      nsub!(/thursday/,'thu')
      nsub!(/thurdsay/,'thu')
      nsub!(/thursady/,'thu')
      nsub!(/\bthurd?\b/,'thu')
      nsub!(/\bthurd?\b/,'thu')
      nsub!(/fridays/,'every fri')
      nsub!(/firdays/,'every fri')
      nsub!(/friday/,'fri')
      nsub!(/firday/,'fri')
      nsub!(/saturdays/,'every sat')
      nsub!(/saturday/,'sat')
      nsub!(/sundays/,'every sun')
      nsub!(/sunday/,'sun')
    end

    def standardize_months
      nsub!(/january/,'jan')
      nsub!(/february/,'feb')
      nsub!(/febr/, 'feb')
      nsub!(/march/,'mar')
      nsub!(/april/,'apr')
      nsub!(/may/,'may')
      nsub!(/june/,'jun')
      nsub!(/july/,'jul')
      nsub!(/august/,'aug')
      nsub!(/september/,'sep')
      nsub!(/sept/,'sep')
      nsub!(/october/,'oct')
      nsub!(/november/,'nov')
      nsub!(/novermber/,'nov')
      nsub!(/novem/,'nov')
      nsub!(/decemb?e?r?/,'dec')
    end

    def standardize_numbers
      nsub!(/\bone\s*-?\s*hundred\b/,'100')
      nsub!(/\bone\s*-?\s*hundredth\b/,'100th')
      nsub!(/\bninety\s*-?\s*nine\b/,'99')
      nsub!(/\bninety\s*-?\s*ninth\b/,'99th')
      nsub!(/\bninety\s*-?\s*eight\b/,'98')
      nsub!(/\bninety\s*-?\s*eighth\b/,'98th')
      nsub!(/\bninety\s*-?\s*seven\b/,'97')
      nsub!(/\bninety\s*-?\s*seventh\b/,'97th')
      nsub!(/\bninety\s*-?\s*six\b/,'96')
      nsub!(/\bninety\s*-?\s*sixth\b/,'96th')
      nsub!(/\bninety\s*-?\s*five\b/,'95')
      nsub!(/\bninety\s*-?\s*fifth\b/,'95th')
      nsub!(/\bninety\s*-?\s*four\b/,'94')
      nsub!(/\bninety\s*-?\s*fourth\b/,'94th')
      nsub!(/\bninety\s*-?\s*three\b/,'93')                   
      nsub!(/\bninety\s*-?\s*third\b/,'93rd')
      nsub!(/\bninety\s*-?\s*two\b/,'92')
      nsub!(/\bninety\s*-?\s*second\b/,'92nd')
      nsub!(/\bninety\s*-?\s*one\b/,'91')
      nsub!(/\bninety\s*-?\s*first\b/,'91st')
      nsub!(/\bninety\b/,'90')
      nsub!(/\bninetieth\b/,'90th')
      nsub!(/\beighty\s*-?\s*nine\b/,'89')
      nsub!(/\beighty\s*-?\s*ninth\b/,'89th')
      nsub!(/\beighty\s*-?\s*eight\b/,'88')
      nsub!(/\beighty\s*-?\s*eighth\b/,'88th')
      nsub!(/\beighty\s*-?\s*seven\b/,'87')                  
      nsub!(/\beighty\s*-?\s*seventh\b/,'87th')
      nsub!(/\beighty\s*-?\s*six\b/,'86')
      nsub!(/\beighty\s*-?\s*sixth\b/,'86th')
      nsub!(/\beighty\s*-?\s*five\b/,'85')
      nsub!(/\beighty\s*-?\s*fifth\b/,'85th')
      nsub!(/\beighty\s*-?\s*four\b/,'84')
      nsub!(/\beighty\s*-?\s*fourth\b/,'84th')
      nsub!(/\beighty\s*-?\s*three\b/,'83')
      nsub!(/\beighty\s*-?\s*third\b/,'83rd')
      nsub!(/\beighty\s*-?\s*two\b/,'82')
      nsub!(/\beighty\s*-?\s*second\b/,'82nd')
      nsub!(/\beighty\s*-?\s*one\b/,'81')
      nsub!(/\beighty\s*-?\s*first\b/,'81st')
      nsub!(/\beighty\b/,'80')
      nsub!(/\beightieth\b/,'80th')
      nsub!(/\bseventy\s*-?\s*nine\b/,'79')
      nsub!(/\bseventy\s*-?\s*ninth\b/,'79th')
      nsub!(/\bseventy\s*-?\s*eight\b/,'78')
      nsub!(/\bseventy\s*-?\s*eighth\b/,'78th')
      nsub!(/\bseventy\s*-?\s*seven\b/,'77')
      nsub!(/\bseventy\s*-?\s*seventh\b/,'77th')
      nsub!(/\bseventy\s*-?\s*six\b/,'76')
      nsub!(/\bseventy\s*-?\s*sixth\b/,'76th')
      nsub!(/\bseventy\s*-?\s*five\b/,'75')
      nsub!(/\bseventy\s*-?\s*fifth\b/,'75th')
      nsub!(/\bseventy\s*-?\s*four\b/,'74')
      nsub!(/\bseventy\s*-?\s*fourth\b/,'74th')
      nsub!(/\bseventy\s*-?\s*three\b/,'73')
      nsub!(/\bseventy\s*-?\s*third\b/,'73rd')
      nsub!(/\bseventy\s*-?\s*two\b/,'72')
      nsub!(/\bseventy\s*-?\s*second\b/,'72nd')
      nsub!(/\bseventy\s*-?\s*one\b/,'71')
      nsub!(/\bseventy\s*-?\s*first\b/,'71st')
      nsub!(/\bseventy\b/,'70')
      nsub!(/\bseventieth\b/,'70th')
      nsub!(/\bsixty\s*-?\s*nine\b/,'69')
      nsub!(/\bsixty\s*-?\s*ninth\b/,'69th')
      nsub!(/\bsixty\s*-?\s*eight\b/,'68')
      nsub!(/\bsixty\s*-?\s*eighth\b/,'68th')
      nsub!(/\bsixty\s*-?\s*seven\b/,'67')
      nsub!(/\bsixty\s*-?\s*seventh\b/,'67th')
      nsub!(/\bsixty\s*-?\s*six\b/,'66')
      nsub!(/\bsixty\s*-?\s*sixth\b/,'66th')
      nsub!(/\bsixty\s*-?\s*five\b/,'65')
      nsub!(/\bsixty\s*-?\s*fifth\b/,'65th')
      nsub!(/\bsixty\s*-?\s*four\b/,'64')
      nsub!(/\bsixty\s*-?\s*fourth\b/,'64th')
      nsub!(/\bsixty\s*-?\s*three\b/,'63')
      nsub!(/\bsixty\s*-?\s*third\b/,'63rd')
      nsub!(/\bsixty\s*-?\s*two\b/,'62')
      nsub!(/\bsixty\s*-?\s*second\b/,'62nd')
      nsub!(/\bsixty\s*-?\s*one\b/,'61')
      nsub!(/\bsixty\s*-?\s*first\b/,'61st')
      nsub!(/\bsixty\b/,'60')
      nsub!(/\bsixtieth\b/,'60th')
      nsub!(/\bfifty\s*-?\s*nine\b/,'59')
      nsub!(/\bfifty\s*-?\s*ninth\b/,'59th')
      nsub!(/\bfifty\s*-?\s*eight\b/,'58')
      nsub!(/\bfifty\s*-?\s*eighth\b/,'58th')
      nsub!(/\bfifty\s*-?\s*seven\b/,'57')
      nsub!(/\bfifty\s*-?\s*seventh\b/,'57th')
      nsub!(/\bfifty\s*-?\s*six\b/,'56')
      nsub!(/\bfifty\s*-?\s*sixth\b/,'56th')
      nsub!(/\bfifty\s*-?\s*five\b/,'55')
      nsub!(/\bfifty\s*-?\s*fifth\b/,'55th')
      nsub!(/\bfifty\s*-?\s*four\b/,'54')
      nsub!(/\bfifty\s*-?\s*fourth\b/,'54th')
      nsub!(/\bfifty\s*-?\s*three\b/,'53')
      nsub!(/\bfifty\s*-?\s*third\b/,'53rd')
      nsub!(/\bfifty\s*-?\s*two\b/,'52')
      nsub!(/\bfifty\s*-?\s*second\b/,'52nd')
      nsub!(/\bfifty\s*-?\s*one\b/,'51')
      nsub!(/\bfifty\s*-?\s*first\b/,'51st')
      nsub!(/\bfifty\b/,'50')
      nsub!(/\bfiftieth\b/,'50th')
      nsub!(/\bfourty\s*-?\s*nine\b/,'49')
      nsub!(/\bfourty\s*-?\s*ninth\b/,'49th')
      nsub!(/\bfourty\s*-?\s*eight\b/,'48')
      nsub!(/\bfourty\s*-?\s*eighth\b/,'48th')
      nsub!(/\bfourty\s*-?\s*seven\b/,'47')
      nsub!(/\bfourty\s*-?\s*seventh\b/,'47th')
      nsub!(/\bfourty\s*-?\s*six\b/,'46')
      nsub!(/\bfourty\s*-?\s*sixth\b/,'46th')
      nsub!(/\bfourty\s*-?\s*five\b/,'45')
      nsub!(/\bfourty\s*-?\s*fifth\b/,'45th')
      nsub!(/\bfourty\s*-?\s*four\b/,'44')
      nsub!(/\bfourty\s*-?\s*fourth\b/,'44th')
      nsub!(/\bfourty\s*-?\s*three\b/,'43')
      nsub!(/\bfourty\s*-?\s*third\b/,'43rd')
      nsub!(/\bfourty\s*-?\s*two\b/,'42')
      nsub!(/\bfourty\s*-?\s*second\b/,'42nd')
      nsub!(/\bfourty\s*-?\s*one\b/,'41')
      nsub!(/\bfourty\s*-?\s*first\b/,'41st')
      nsub!(/\bfourty\b/,'40')
      nsub!(/\bfourtieth\b/,'40th')
      nsub!(/\bthirty\s*-?\s*nine\b/,'39')
      nsub!(/\bthirty\s*-?\s*ninth\b/,'39th')
      nsub!(/\bthirty\s*-?\s*eight\b/,'38')
      nsub!(/\bthirty\s*-?\s*eighth\b/,'38th')
      nsub!(/\bthirty\s*-?\s*seven\b/,'37')
      nsub!(/\bthirty\s*-?\s*seventh\b/,'37th')
      nsub!(/\bthirty\s*-?\s*six\b/,'36')
      nsub!(/\bthirty\s*-?\s*sixth\b/,'36th')
      nsub!(/\bthirty\s*-?\s*five\b/,'35')
      nsub!(/\bthirty\s*-?\s*fifth\b/,'35th')
      nsub!(/\bthirty\s*-?\s*four\b/,'34')
      nsub!(/\bthirty\s*-?\s*fourth\b/,'34th')
      nsub!(/\bthirty\s*-?\s*three\b/,'33')
      nsub!(/\bthirty\s*-?\s*third\b/,'33rd')
      nsub!(/\bthirty\s*-?\s*two\b/,'32')
      nsub!(/\bthirty\s*-?\s*second\b/,'32nd')
      nsub!(/\bthirty\s*-?\s*one\b/,'31')
      nsub!(/\bthirty\s*-?\s*first\b/,'31st')
      nsub!(/\bthirty\b/,'30')
      nsub!(/\bthirtieth\b/,'30th')
      nsub!(/\btwenty\s*-?\s*nine\b/,'29')
      nsub!(/\btwenty\s*-?\s*ninth\b/,'29th')
      nsub!(/\btwenty\s*-?\s*eight\b/,'28')
      nsub!(/\btwenty\s*-?\s*eighth\b/,'28th')
      nsub!(/\btwenty\s*-?\s*seven\b/,'27')
      nsub!(/\btwenty\s*-?\s*seventh\b/,'27th')
      nsub!(/\btwenty\s*-?\s*six\b/,'26')
      nsub!(/\btwenty\s*-?\s*sixth\b/,'26th')
      nsub!(/\btwenty\s*-?\s*five\b/,'25')
      nsub!(/\btwenty\s*-?\s*fifth\b/,'25th')
      nsub!(/\btwenty\s*-?\s*four\b/,'24')
      nsub!(/\btwenty\s*-?\s*fourth\b/,'24th')
      nsub!(/\btwenty\s*-?\s*three\b/,'23')
      nsub!(/\btwenty\s*-?\s*third\b/,'23rd')
      nsub!(/\btwenty\s*-?\s*two\b/,'22')
      nsub!(/\btwenty\s*-?\s*second\b/,'22nd')
      nsub!(/\btwenty\s*-?\s*one\b/,'21')
      nsub!(/\btwenty\s*-?\s*first\b/,'21st')
      nsub!(/\btwenty\b/,'20')
      nsub!(/\btwentieth\b/,'20th')
      nsub!(/\bnineteen\b/,'19')
      nsub!(/\bnineteenth\b/,'19th')
      nsub!(/\beighteen\b/,'18')
      nsub!(/\beighteenth\b/,'18th')
      nsub!(/\bseventeen\b/,'17')
      nsub!(/\bseventeenth\b/,'17th')
      nsub!(/\bsixteen\b/,'16')
      nsub!(/\bsixteenth\b/,'16th')
      nsub!(/\bfifteen\b/,'15')
      nsub!(/\bfifteenth\b/,'15th')
      nsub!(/\bfourteen\b/,'14')
      nsub!(/\bfourteenth\b/,'14th')
      nsub!(/\bthirteen/,'13')
      nsub!(/\bthirteenth/,'13th')
      nsub!(/\btwelve\b/,'12')
      nsub!(/\btwelfth\b/,'12th')
      nsub!(/\beleven\b/,'11')
      nsub!(/\beleventh\b/,'11th')
      nsub!(/\bten\b/,'10')
      nsub!(/\btenth\b/,'10th')
      nsub!(/\bnine\b/,'9')
      nsub!(/\bninth\b/,'9th')
      nsub!(/\beight\b/,'8')
      nsub!(/\beighth\b/,'8th')
      nsub!(/\bseven\b/,'7')
      nsub!(/\bseventh\b/,'7th')
      nsub!(/\bsix\b/,'6')
      nsub!(/\bsixth\b/,'6th')
      nsub!(/\bfive\b/,'5')
      nsub!(/\bfifth\b/,'5th')
      nsub!(/\bfour\b/,'4')
      nsub!(/\bfourth\b/,'4th')
      nsub!(/\bthree\b/,'3')
      nsub!(/\bthird\b/,'3rd')
      nsub!(/\btwo\b/,'2')
      nsub!(/\bsecond\b/,'2nd')
      nsub!(/\bone\b/,'1')
      nsub!(/\bfirst\b/,'1st')
      nsub!(/\bzero\b/,'0')
      nsub!(/\bzeroth\b/,'0th')  
    end

    def standardize_am_pm
      nsub!(/([0-9])(?:\s*)a\b/,'\1am')  # allows 5a as 5am
      nsub!(/([0-9])(?:\s*)p\b/,'\1pm')  # allows 5p as 5pm
      nsub!(/\s+am\b/,'am')  # removes any spaces before am, shouldn't I check for preceeding digits?
      nsub!(/\s+pm\b/,'pm')  # removes any spaces before pm, shouldn't I check for preceeding digits?
    end

    def replace_hyphens
      nsub!(/--?/,' through ')
    end

    def insert_repeats_before_words_indicating_recurrence_lame
      comps = self.split
      (daily_index = comps.index("daily")) && comps[daily_index - 1] != "repeats" && comps[daily_index] = "repeats daily"
      (weekly_index = comps.index("weekly")) && comps[weekly_index - 1] != "repeats" && comps[weekly_index] = "repeats weekly"
      (monthly_index = comps.index("monthly")) && comps[monthly_index - 1] != "repeats" && comps[monthly_index] = "repeats monthly"
      if (rejoin = comps.join(' ')) != self
        nsub!(/.+/,rejoin)
      end
    end

    def insert_space_at_end_of_string_lame
  #      nsub!(/(.+)/,'\1 ')  # I don't really want to be notified about this
      gsub!(/(.+)/,'\1 ')
    end

    # These are possible because: NLPQuery.new("hi there").split[0].class ==> Nickel::NLPQuery!!
    # valid hour, 24hour, and minute could use some cleaning
    def valid_dd?
      self =~ %r{^(0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)?$}
    end
    def valid_hour?
      validity = false
      if (self.length == 1) && (self =~ /^(1|2|3|4|5|6|7|8|9)/)
        validity = true
      end
      if self.length == 2
        if self =~ /^0/
          if self =~ /(1|2|3|4|5|6|7|8|9)$/
            validity = true
          end
        end
        if self =~ /^1/
          if self =~ /(0|1|2)$/
            validity = true
          end
        end
      end
      return validity
    end # END valid_hour?
    def valid_24_hour?
      validity = false
      if (self.length == 1) && (self =~ /^(0|1|2|3|4|5|6|7|8|9)/)
        validity = true
      end
      if self.length == 2
        if self =~ /^(0|1)/
          if self =~ /(0|1|2|3|4|5|6|7|8|9)$/
            validity = true
          end
        end
        if self =~ /^2/
          if self =~ /(0|1|2|3)$/
            validity = true
          end
        end
      end
      return validity
    end # END valid_hour?
    def valid_minute?
      validity = false
      if self.length <= 2
        if self =~ /^(0|1|2|3|4|5)/
          if self =~ /(0|1|2|3|4|5|6|7|8|9)$/
            validity = true
          end
        end
      end
      return validity
    end # END valid_minute?
    def digits_only?
      self =~ /^\d+$/ #no characters other than digits
    end

    # Interpret Time is an important one, set some goals:
    #     match all of the following
    #     a.) 5,   12,   530,    1230,     2000
    #     b.) 5pm, 12pm, 530am,  1230am,
    #     c.)            5:30,   12:30,    20:00
    #     d.)            5:3,    12:3,     20:3    ...  that's not needed but we supported it in version 1, this would be 5:30 and 12:30
    #     e.)            5:30am, 12:30am
    #     20:00am, 20:00pm ... ZTime will flag these as invalid, so it is ok if we match them here
    def interpret_time
      a_b   = /^(\d{1,4})(am|pm)?$/                     # handles cases (a) and (b)
      c_d_e = /^(\d{1,2}):(\d{1,2})(am|pm)?$/           # handles cases (c), (d), and (e)
      if mdata = match(a_b)
        am_pm = mdata[2]
        case mdata[1].length                            # this may look a bit confusing, but all we are doing is interpreting    
          when 1 then hstr = "0" + mdata[1]                 # what the user meant based on the number of digits they provided
          when 2 then hstr = mdata[1]                                       # e.g. "11" means 11:00
          when 3 then hstr = "0" + mdata[1][0..0]; mstr = mdata[1][1..2]    # e.g. "530" means 5:30
          when 4 then hstr = mdata[1][0..1]; mstr = mdata[1][2..3]          # e.g. "1215" means 12:15
        end
      elsif mdata = match(c_d_e)
        am_pm = mdata[3]
        hstr = mdata[1]
        mstr = mdata[2]
        hstr.length == 1 && hstr.insert(0,"0")
        mstr.length == 1 && mstr << "0"
      else
        return nil
      end
      # in this case we do not care if time fails validation, if it does, it just means we haven't found a valid time, return nil
      begin ZTime.new("#{hstr}#{mstr}", am_pm) rescue return nil end 
    end

    # Interpret Date is equally as important, our goals:
    # First off, convention of the NLP is to not allow month names to the construct finder (unless it is implying date span), so we will not be interpreting
    # anything such as january 2nd, 2008.  Instead all dates will be represented in this form month/day/year.  However it may not
    # be as nice as that.  We need to match things like '5', if someone just typed in "the 5th."  Because of this, there will be 
    # overlap between interpret_date and interpret_time in matching; interpret_date should ALWAYS be found after interpret_time in 
    # the construct finder.  If the construct finder happens upon a digit on it's own, e.g. "5", it will not run interpret_time
    # because there is no "at" preceeding it.  Therefore it will fall through to the finder with interpret_date and we will assume
    # the user meant the 5th.  If interpret_date is before interpret_time, then .... wait... does the order actually matter?  Even if
    # this is before interpret_time, it shouldn't get hit because the time should be picked up at the "at" construct.  This may be a bunch
    # of useless rambling.
    # 
    # 2/08      <------ This is not A date
    # 2/2008    <------ Neither is this, but I can see people using these as wrappers, must support this in next version
    # 11/08     <------ same
    # 11/2008   <------ same
    # 2/1/08,   2/12/08,  2/1/2008,   2/12/2008
    # 11/1/08,  11/12/08, 11/1/2008, 11/12/2008
    # 2/1     feb first
    # 2/12    feb twelfth
    # 11/1    nov first
    # 11/12   nov twelfth
    # 11      the 11th
    # 2       the 2nd
    #
    #
    # Match all of the following:
    #   a.) 1   10
    #   b.) 1/1  1/12  10/1  10/12
    #   c.) 1/1/08 1/12/08 1/1/2008 1/12/2008 10/1/08 10/12/08 10/12/2008 10/12/2008
    #   d.) 1st 10th
    def interpret_date(current_date)
      day_str, month_str, year_str = nil, nil, nil
      ambiguous = {:month => false, :year => false}   # assume false, we use this flag if we aren't certain about the year

      #appropriate matches
      a_d = /^(\d{1,2})(rd|st|nd|th)?$/     # handles cases a and d
      b = /^(\d{1,2})\/(\d{1,2})$/          # handles case b
      c = /^(\d{1,2})\/(\d{1,2})\/(\d{2}|\d{4})$/   # handles case c
      
      if mdata = match(a_d)
        ambiguous[:month] = true
        day_str = mdata[1].to_s2
      elsif mdata = match(b)
        ambiguous[:year] = true
        month_str = mdata[1].to_s2
        day_str = mdata[2].to_s2
      elsif mdata = match(c)
        month_str = mdata[1].to_s2
        day_str = mdata[2].to_s2
        year_str = mdata[3].sub(/^(\d\d)$/,'20\1')    # if there were only two digits, prepend 20 (e.g. "08" should be "2008")
      else
        return nil
      end
      
      inst_str = (year_str || current_date.year_str) + (month_str || current_date.month_str) + (day_str || current_date.day_str)
      # in this case we do not care if date fails validation, if it does, it just means we haven't found a valid date, return nil
      date = ZDate.new(inst_str) rescue nil
      if date && NLP::use_date_correction
        if ambiguous[:year]
          # say the date is 11/1 and someone enters 2/1, they probably mean next year, I pick 4 months as a threshold but that is totally arbitrary
          current_date.diff_in_months(date) < -4 and date = date.add_years(1)
        elsif ambiguous[:month]
          current_date.day > date.day and date = date.add_months(1)
        end
      end
      date
    end


    def extract_message(constructs)
      @logger = Logger.new(STDOUT)
      def @logger.blue(a)
        #self.warn "\e[44m #{a.inspect} \e[0m"
      end
      
      @logger.blue self
      # message could be all components put back together (which would be @nlp_query), so start with that
      message_array = self.split
      
      # now iterate through constructs, blow away any words between positions comp_start and comp_end
      constructs.each do |c|
        # create a range between comp_start and comp_end, iterate through it and wipe out words between them
        (c.comp_start..c.comp_end).each {|x| message_array[x] = nil}
        # also wipe out words before comp start if it is something like in, at, on, or the
        if c.comp_start - 1 >= 0 && message_array[c.comp_start - 1] =~ /\b(from|in|at|on|the|are|is|for)\b/
          message_array[c.comp_start - 1] = nil
          if $1 == "the" && c.comp_start - 2 >= 0 && message_array[c.comp_start - 2] =~ /\b(for|on)\b/    # for the next three days;  on the 27th;
            message_array[c.comp_start - 2] = nil
            if $1 == "on" && c.comp_start - 3 >= 0 && message_array[c.comp_start - 3] =~ /\b(is|are)\b/         # is on the 28th;  are on the 21st and 22nd;
              message_array[c.comp_start - 3] = nil
            end
          elsif $1 == "on" && c.comp_start - 2 >= 0 && message_array[c.comp_start - 2] =~ /\b(is|are)\b/      # is on tuesday; are on tuesday and wed; 
            message_array[c.comp_start - 2] = nil
          end
        end
        @logger.blue(message_array)
        @logger.blue(c.comp_start)
        @logger.blue(c.comp_end)
      end
      
      # reloop and wipe out words after end of constructs, if they are followed by another construct
      # note we already wiped out terms ahead of the constructs, so be sure to check for nil values, these indicate that a construct is followed by the nil
      constructs.each_with_index do |c, i|
        if message_array[c.comp_end+1] && message_array[c.comp_end + 1] == "and"    # do something tomorrow and on friday
          if message_array[c.comp_end + 2].nil? || (constructs[i+1] && constructs[i+1].comp_start == c.comp_end + 2)
            message_array[c.comp_end + 1] = nil
          elsif message_array[c.comp_end + 2] == "also" && message_array[c.comp_end + 3].nil? || (constructs[i+1] && constructs[i+1].comp_start == c.comp_end + 3)    # do something tomorrow and also on friday
            message_array[c.comp_end + 1] = nil
            message_array[c.comp_end + 2] = nil
          end
        end
      end
      @logger.blue("final:")
      @logger.blue(message_array)
      @message = message_array.compact.join(" ")   # remove nils and join the words with spaces
      # we have the message, now run the case corrector to return cases to the users original input
      case_corrector
    end
    
    # returns any words in the query that appeared as input to their original case
    def case_corrector
      orig = @query.split
      latest = @message.split
      orig.each_with_index do |original_word,j|
        if i = latest.index(original_word.downcase)
          latest[i] = original_word
        end
      end
      @message = latest.join(" ")
    end
    

    private
    def standardize_input
      nsub!(/last\s+#{DAY_OF_WEEK}/,'5th \1')     # last dayname  =>  5th dayname
      nsub!(/\ba\s+(week|month|day)/, '1 \1')     # a month|week|day  =>  1 month|week|day
      nsub!(/^(through|until)/,'today through')   # ^through  =>  today through
      nsub!(/every\s*(night|morning)/,'every day')
      nsub!(/tonight/,'today')
      nsub!(/this(?:\s*)morning/,'today')
      nsub!(/before\s+12pm/,'6am to 12pm')        # arbitrary

      # Handle 'THE' Cases
      # Attempt to pick out where a user entered 'the' when they really mean 'every'. 
      # For example, 
      # The first of every month and the 22nd of THE month  =>  repeats monthly first xxxxxx repeats monthly 22nd xxxxxxx
      nsub!(/(?:the\s+)?#{DATE_DD_WITH_SUFFIX}\s+(?:of\s+)?(?:every|each)\s+month((?:.*)of\s+the\s+month(?:.*))/) do |m1,m2|
        ret_str = " repeats monthly " + m1
        ret_str << m2.gsub(/(?:and\s+)?(?:the\s+)?#{DATE_DD_WITH_SUFFIX}\s+of\s+the\s+month/, ' repeats monthly \1 ')
      end
      
      # Every first sunday of the month and the last tuesday  =>  repeats monthly first sunday xxxxxxxxx repeats monthly last tuesday xxxxxxx
      nsub!(/every\s+#{WEEK_OF_MONTH}\s+#{DAY_OF_WEEK}\s+of\s+(?:the\s+)?month((?:.*)and\s+(?:the\s+)?#{WEEK_OF_MONTH}\s+#{DAY_OF_WEEK}(?:.*))/) do |m1,m2,m3|
        ret_str = " repeats monthly " + m1 + " " + m2 + " "
        ret_str << m3.gsub(/and\s+(?:the\s+)?#{WEEK_OF_MONTH}\s+#{DAY_OF_WEEK}(?:\s*)(?:of\s+)?(?:the\s+)?(?:month\s+)?/, ' repeats monthly \1 \2 ')
      end

      # The x through the y of oct z  =>  10/x/z through 10/y/z
      nsub!(/(?:the\s+)?#{DATE_DD}\s+(?:through|to|until)\s+(?:the\s+)?#{DATE_DD}\s(?:of\s+)#{MONTH_OF_YEAR}\s+(?:of\s+)?#{YEAR}/) do |m1,m2,m3,m4|
        (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m1 + '/' + m4 + ' through ' +  (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m2 + '/' + m4
      end
      
      # The x through the y of oct  =>  10/x through 10/y
      nsub!(/(?:the\s+)?#{DATE_DD}\s+(?:through|to|until)\s+(?:the\s+)#{DATE_DD}\s(?:of\s+)?#{MONTH_OF_YEAR}/) do |m1,m2,m3|
        (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m1 + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m2
      end

      # Monthname x through y
      nsub!(/#{MONTH_OF_YEAR}\s+(?:the\s+)?#{DATE_DD_NB_ON_SUFFIX}\s+(?:of\s+)?(?:#{YEAR}\s+)?(?:through|to|until)\s+(?:the\s+)?#{DATE_DD_NB_ON_SUFFIX}(?:\s+of)?(?:\s+#{YEAR})?/) do |m1,m2,m3,m4,m5|
        if m3  # $3 holds first occurrence of year
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + '/' + m3 +' through ' + (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m4 + '/' + m3
        elsif m5 # $5 holds second occurrence of year
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + '/' + m5 +' through ' + (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m4 + '/' + m5
        else
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + ' through ' + (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m4
        end
      end
      
      # Monthname x through monthname y
      # Jan 14 through jan 18  =>  1/14 through 1/18
      # Oct 2 until oct 5
      nsub!(/#{MONTH_OF_YEAR}\s+#{DATE_DD_NB_ON_SUFFIX}\s+(?:to|through|until)\s+#{MONTH_OF_YEAR}\s+#{DATE_DD_NB_ON_SUFFIX}\s+(?:of\s+)?(?:#{YEAR})?/) do |m1,m2,m3,m4,m5|
        if m5
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + '/' + m5 + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m4 + '/' + m5 + ' '
        else
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m4 + ' '
        end       
      end
    
      # Mnday the 23rd, tuesday the 24th and wed the 25th of oct  =>  11/23 11/24 11/25
      nsub!(/((?:#{DAY_OF_WEEK_NB}\s+the\s+#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?){1,31})of\s+#{MONTH_OF_YEAR}\s*(#{YEAR})?/) do |m1,m2,m3|
        month_str = (ZDate.months_of_year.index(m2) + 1).to_s
        if m3
          m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK}/,'').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1/' + m3)
        else                                                 
          m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK}/,'').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1')
        end
      end
      
      # the 23rd and 24th of october                    =>  11/23 11/24
      # the 23rd, 24th, and 25th of october             =>  11/23 11/24 11/25                                                                                                                                              
      # the 23rd, 24th, and 25th of october 2010        =>  11/23/2010 11/24/2010 11/25/2010
      # monday and tuesday, the 23rd and 24th of july   =>  7/23 7/24
      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:day\s+)?(?:in\s+)?(?:of\s+)#{MONTH_OF_YEAR}\s*(#{YEAR})?/) do |m1,m2,m3|
        month_str = (ZDate.months_of_year.index(m2) + 1).to_s
        if m3
          m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK}/,'').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1/' + m3)
        else                                                 
          m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK}/,'').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1')
        end
      end

      # Match date with year first.
      # Don't allow mixing of suffixes, e.g. "dec 3rd 2008 at 4 and dec 5 2008 9 to 5"
      # Dec 2nd, 3rd, and 5th 2008  => 12/2/2008 12/2/2008 12/5/2008
      # Mon nov 23rd 08
      # Dec 2, 3, 5, 2008  =>  12/2/2008 12/3/2008 12/5/2008
      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR}\s+((?:(?:the\s+)?#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?){1,31})#{YEAR}/) do |m1,m2,m3|
        month_str = (ZDate.months_of_year.index(m1) + 1).to_s
        m2.gsub(/\b(and|the)\b/,'').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1/' + m3)
      end
      
      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR}\s+((?:(?:the\s+)?#{DATE_DD_WITHOUT_SUFFIX_NB}\s+(?:and\s+)?){1,31})#{YEAR}/) do |m1,m2,m3|
        month_str = (ZDate.months_of_year.index(m1) + 1).to_s
        m2.gsub(/\b(and|the)\b/,'').gsub(/#{DATE_DD_WITHOUT_SUFFIX}/, month_str + '/\1/' + m3)
      end
      
      # Dec 2nd, 3rd, and 4th  =>  12/2, 12/3, 12/4                                                                                                
      # Note: dec 5 9 to 5 will give an error, need to find these and convert to dec 5 from 9 to 5; also dec 3,4, 9 to|through 5 --> dec 3, 4 from 9 through 5
      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR}\s+(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1,m2|
        month_str = (ZDate.months_of_year.index(m1) + 1).to_s                                                                                        
        m2.gsub(/(and|the)/,'').gsub(/#{DATE_DD_NB_ON_SUFFIX}/) {month_str + '/' + $1}  # that $1 is from the nested match!
      end
      
      # jan 4 2-3 has to be modified, but
      # jan 24 through jan 26 cannot!
      # not real sure what this one is doing
      # "dec 2, 3, and 4" --> 12/2, 12/3, 12/4       
      # "mon, tue, wed, dec 2, 3, and 4" --> 12/2, 12/3, 12/4       
      nsub!(/(#{MONTH_OF_YEAR_NB}\s+(?:the\s+)?(?:(?:#{DATE_DD_WITHOUT_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:to|through|until)\s+#{DATE_DD_WITHOUT_SUFFIX_NB})/) { |m1| m1.gsub(/#{DATE_DD_WITHOUT_SUFFIX}\s+(to|through|until)/, 'from \1 through ') }
      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR}\s+(?:the\s+)?((?:#{DATE_DD_WITHOUT_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1,m2|
        month_str = (ZDate.months_of_year.index(m1) + 1).to_s                                                                                        
        m2.gsub(/(and|the)/,'').gsub(/#{DATE_DD_NB_ON_SUFFIX}/) {month_str + '/' + $1}  # $1 from nested match
      end
      
      # "monday 12/6" --> 12/6
      nsub!(/#{DAY_OF_WEEK_NB}\s+(#{DATE_MM_SLASH_DD})/,'\1')
      
      # "next friday to|until|through the following tuesday" --> 10/12 through 10/16
      # "next friday through sunday" --> 10/12 through 10/14
      # "next friday and the following sunday" --> 11/16 11/18
      # we are not going to do date calculations here anymore, so instead:
      # next friday to|until|through the following tuesday" --> next friday through tuesday
      # next friday and the following sunday --> next friday and sunday
      nsub!(/next\s+#{DAY_OF_WEEK}\s+(to|until|through|and)\s+(?:the\s+)?(?:following|next)?(?:\s*)#{DAY_OF_WEEK}/) do |m1,m2,m3|
        connector = (m2 =~ /and/ ? ' ' : ' through ')
        "next " + m1 + connector + m3
      end

      # "this friday to|until|through the following tuesday" --> 10/5 through 10/9
      # "this friday through following sunday" --> 10/5 through 10/7
      # "this friday and the following monday" --> 11/9 11/12
      # No longer performing date calculation
      # this friday and the following monday --> fri mon
      # this friday through the following tuesday --> fri through tues
      nsub!(/(?:this\s+)?#{DAY_OF_WEEK}\s+(to|until|through|and)\s+(?:the\s+)?(?:this|following)(?:\s*)#{DAY_OF_WEEK}/) do |m1,m2,m3|
        connector = (m2 =~ /and/ ? ' ' : ' through ')
        m1 + connector + m3
      end
      
      # "the wed after next" --> 2 wed from today
      nsub!(/(?:the\s+)?#{DAY_OF_WEEK}\s+(?:after|following)\s+(?:the\s+)?next/,'2 \1 from today')
      
      # "mon and tue" --> mon tue
      nsub!(/(#{DAY_OF_WEEK}\s+and\s+#{DAY_OF_WEEK})(?:\s+and)?/,'\2 \3')
      
      # "mon wed every week" --> every mon wed
      nsub!(/((#{DAY_OF_WEEK}(?:\s*)){1,7})(?:of\s+)?(?:every|each)(\s+other)?\s+week/,'every \4 \1')
      
      # "every 2|3 weeks" --> every 2nd|3rd week
      nsub!(/(?:repeats\s+)?every\s+(2|3)\s+weeks/) {|m1| "every " + m1.to_i.ordinalize + " week"}
      
      # "every week on mon tue fri" --> every mon tue fri
      nsub!(/(?:repeats\s+)?every\s+(?:(other|3rd|2nd)\s+)?weeks?\s+(?:\bon\s+)?((?:#{DAY_OF_WEEK_NB}\s+){1,7})/,'every \1 \2')
      
      # "every mon and every tue and.... " --> every mon tue ...
      nsub!(/every\s+#{DAY_OF_WEEK}\s+(?:and\s+)?every\s+#{DAY_OF_WEEK}(?:\s+(?:and\s+)?every\s+#{DAY_OF_WEEK})?(?:\s+(?:and\s+)?every\s+#{DAY_OF_WEEK})?(?:\s+(?:and\s+)?every\s+#{DAY_OF_WEEK})?/,'every \1 \2 \3 \4 \5')
      
      # monday, wednesday, and friday next week at 8
      nsub!(/((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})(?:of\s+)?(this|next)\s+week/, '\2 \1')
      
      # "every day this|next week"  --> returns monday through friday of the closest week, kinda stupid
      # doesn't do that anymore, no date calculations allowed here, instead just formats it nicely for construct finders --> every day this|next week
      nsub!(/every\s+day\s+(?:of\s+)?(this|the|next)\s+week\b./) {|m1| m1 == 'next' ? "every day next week" : "every day this week"}
      
      # "every day for the next week" --> "every day this week"
      nsub!(/every\s+day\s+for\s+(the\s+)?(next|this)\s+week/, 'every day this week')
      
      # "this weekend" --> sat sun
      nsub!(/(every\s+day\s+|both\s+days\s+)?this\s+weekend(\s+on)?(\s+both\s+days|\s+every\s+day|\s+sat\s+sun)?/,'sat sun')
      
      # "this weekend including mon" --> sat sun mon
      nsub!(/sat\s+sun\s+(and|includ(es?|ing))\s+mon/,'sat sun mon')
      nsub!(/sat\s+sun\s+(and|includ(es?|ing))\s+fri/,'fri sat sun')

      # Note: next weekend including monday will now fail.  Need to make constructors find "next sat sun mon"
      # "next weekend" --> next weekend
      nsub!(/(every\s+day\s+|both\s+days\s+)?next\s+weekend(\s+on)?(\s+both\s+days|\s+every\s+day|\s+sat\s+sun)?/,'next weekend')
      
      # "next weekend including mon" --> next sat sun mon
      nsub!(/next\s+weekend\s+(and|includ(es?|ing))\s+mon/,'next sat sun mon')
      nsub!(/next\s+weekend\s+(and|includ(es?|ing))\s+fri/,'next fri sat sun')
      
      # "every weekend" --> every sat sun
      nsub!(/every\s+weekend(?:\s+(?:and|includ(?:es?|ing))\s+(mon|fri))?/,'every sat sun' + ' \1')  # regarding "every sat sun fri", order should not matter after "every" keyword
      
      # "weekend" --> sat sun     !!! catch all
      nsub!(/weekend/,'sat sun')
      
      # "mon through wed" -- >  mon tue wed
      # CATCH ALL FOR SPANS, TRY NOT TO USE THIS
      nsub!(/#{DAY_OF_WEEK}\s+(?:through|to|until)\s+#{DAY_OF_WEEK}/) do |m1,m2|
        index1 = ZDate.days_of_week.index(m1)
        index2 = ZDate.days_of_week.index(m2)
        i = index1
        ret_string = ''
        if index2 > index1
          while i <= index2
            ret_string << ZDate.days_of_week[i] + ' '
            i += 1
          end
        elsif index2 < index1
          begin
            ret_string << ZDate.days_of_week[i] + ' '
            i = (i + 1) % 7
          end while i != index2 + 1     # wrap until it hits index2
        else
          # indices are the same, one week event
          8.times do
            ret_string << ZDate.days_of_week[i] + ' '
            i = (i + 1) % 7
          end
        end
        ret_string      
      end
      
      # "every day" --> repeats daily
      nsub!(/\b(repeat(?:s|ing)?|every|each)\s+da(ily|y)\b/,'repeats daily')
      
      # "every other week starting this|next fri" --> every other friday starting this friday
      nsub!(/every\s+(3rd|other)\s+week\s+(?:start(?:s|ing)?|begin(?:s|ning)?)\s+(this|next)\s+#{DAY_OF_WEEK}/,'every \1 \3 start \2 \3')
      
      # "every other|3rd friday starting this|next week" --> every other|3rd friday starting this|next friday
      nsub!(/every\s+(3rd|other)\s+#{DAY_OF_WEEK}\s+(?:start(?:s|ing)?|begin(?:s|ning)?)\s+(this|next)\s+week/,'every \1 \2 start \3 \2')
      
      # "repeats monthly on the 1st and 2nd friday" --> repeats monthly 1st friday 2nd friday
      # "repeats every other month on the 1st and 2nd friday" --> repeats monthly 1st friday 2nd friday
      # "repeats every three months on the 1st and 2nd friday" --> repeats threemonthly 1st friday 2nd friday
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/)          { |m1,m2| "repeats monthly " +  m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/) { |m1,m2| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/)           { |m1,m2| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/)          { |m1,m2| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/) { |m1,m2| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/)           { |m1,m2| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      
      # "repeats monthly on the 1st friday" --> repeats monthly 1st friday
      # "repeats monthly on the 1st friday, second tuesday, and third friday" --> repeats monthly 1st friday 2nd tuesday 3rd friday
      # "repeats every other month on the 1st friday, second tuesday, and third friday" --> repeats monthly 1st friday 2nd tuesday 3rd friday
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/)                 { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/) { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/)           { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/)                 { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/) { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/)           { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      
      # "repeats monthly on the 1st friday saturday" --> repeats monthly 1st friday 1st saturday
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)                  { |m1,m2| "repeats monthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)  { |m1,m2| "repeats altmonthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)            { |m1,m2| "repeats threemonthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)                  { |m1,m2| "repeats monthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)  { |m1,m2| "repeats altmonthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)            { |m1,m2| "repeats threemonthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      
      # "21st of each month" --> repeats monthly 21st
      # "on the 21st, 22nd and 25th of each month" --> repeats monthly 21st 22nd 25th
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:days?\s+)?(?:of\s+)?(?:each|all|every)\s+\bmonths?/)                  { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:days?\s+)?(?:of\s+)?(?:each|all|every)\s+(?:other|2n?d?)\s+months?/)  { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:days?\s+)?(?:of\s+)?(?:each|all|every)\s+3r?d?\s+months?/)            { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      
      # "repeats each month on the 22nd" --> repeats monthly 22nd
      # "repeats monthly on the 22nd 23rd and 24th" --> repeats monthly 22nd 23rd 24th
      # This can ONLY handle multi-day recurrence WITHOUT independent times for each, i.e. "repeats monthly on the 22nd at noon and 24th from 1 to 9"  won't work; that's going to be a tricky one.
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " " }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
     #nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?\bmonth(?:s|ly)\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?\bmonthly\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " " }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
     #nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:s|ly)\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " " }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
     #nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?3r?d?\s+month(?:s|ly)\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
     
      # "on day 4 of every month" --> repeats monthly 4
      # "on days 4 9 and 14 of every month" --> repeats monthly 4 9 14
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:day|date)s?\s+((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)(every|all|each)\s+\bmonths?/) { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " " }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:day|date)s?\s+((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)(every|all|each)\s+(?:other|2n?d?)\s+months?/) { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " " }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:day|date)s?\s+((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)(every|all|each)\s+3r?d?\s+months?/) { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " " }
      
      # "every 22nd of the month" --> repeats monthly 22
      # "every 22nd 23rd and 25th of the month" --> repeats monthly 22 23 25
      nsub!(/(?:repeats\s+)?(?:every|each)\s+((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:day\s+)?(?:of\s+)?(?:the\s+)?\bmonth/) { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:every|each)\s+other\s+((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:day\s+)?(?:of\s+)?(?:the\s+)?\bmonth/) { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      
      # "every 1st and 2nd fri of the month" --> repeats monthly 1st fri 2nd fri
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) { |m1,m2| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+other\s+((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) { |m1,m2| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      
      # "every 1st friday of the month" --> repeats monthly 1st friday
      # "every 1st friday and 2nd tuesday of the month" --> repeats monthly 1st friday 2nd tuesday
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/)  { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+other\s+((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/)  { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      
      # "every 1st fri sat of the month" --> repeats monthly 1st fri 1st sat
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/)          { |m1,m2| "repeats monthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+other\s+(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/)  { |m1,m2| "repeats altmonthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      
      # "the 1st and 2nd friday of every month" --> repeats monthly 1st friday 2nd friday
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all)\s+)\bmonths?/)                 { |m1,m2| "repeats monthly " +  m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all)\s+)(?:other|2n?d?)\s+months?/) { |m1,m2| "repeats altmonthly " +  m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all)\s+)3r?d?\s+months?/)           { |m1,m2| "repeats threemonthly " +  m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      
      # "the 1st friday of every month" --> repeats monthly 1st friday
      # "the 1st friday and the 2nd tuesday of every month" --> repeats monthly 1st friday 2nd tuesday
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all)\s+)\bmonths?/)                   { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all)\s+)(?:other|2n?d?)\s+months?/)   { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all)\s+)3r?d?\s+months?/)             { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      
      # "the 1st friday saturday of every month" --> repeats monthly 1st friday 1st saturday
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all)\s+)\bmonths?/)                  { |m1,m2| "repeats monthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all)\s+)(?:other|2n?d?)\s+months?/)  { |m1,m2| "repeats altmonthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all)\s+)3r?d?\s+months?/)            { |m1,m2| "repeats threemonthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      
      # "repeats on the 1st and second friday of the month" --> repeats monthly 1st friday 2nd friday
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all|the)\s+)?\bmonths?/)                 { |m1,m2| "repeats monthly " +  m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all|the)\s+)?(?:other|2n?d?)\s+months?/) { |m1,m2| "repeats altmonthly " +  m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all|the)\s+)?3r?d?\s+months?/)           { |m1,m2| "repeats threemonthly " +  m1.gsub(/\b(and|the)\b/,'').split.join(" " + m2 + " ") + " " + m2 + " " }
      
      # "repeats on the 1st friday of the month --> repeats monthly 1st friday
      # "repeats on the 1st friday and second tuesday of the month" --> repeats monthly 1st friday 2nd tuesday
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all|the)\s+)?\bmonths?/)                   { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all|the)\s+)?(?:other|2n?d?)\s+months?/)   { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all|the)\s+)?3r?d?\s+months?/)             { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      
      # "repeats on the 1st friday saturday of the month" --> repeats monthly 1st friday 1st saturday
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all|the)\s+)?\bmonths?/)                  { |m1,m2| "repeats monthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all|the)\s+)?(?:other|2n?d?)\s+months?/)  { |m1,m2| "repeats altmonthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all|the)\s+)?3r?d?\s+months?/)            { |m1,m2| "repeats threemonthly " + m1 + " " + m2.split.join(" " + m1 + " ") + " "}
      
      # "repeats each month" --> every month
      nsub!(/(repeats\s+)?(each|every)\s+\bmonth(ly)?/,'every month ')
      nsub!(/all\s+months/,'every month')
      
      # "repeats every other month" --> every other month    
      nsub!(/(repeats\s+)?(each|every)\s+(other|2n?d?)\s+month(ly)?/,'every other month ')
      nsub!(/(repeats\s+)?bimonthly/,'every other month ')    # hyphens have already been replaced in spell check (bi-monthly)
      
      # "repeats every three months" --> every third month
      nsub!(/(repeats\s+)?(each|every)\s+3r?d?\s+month/,'every third month ')
      nsub!(/(repeats\s+)?trimonthly/,'every third month ')

      # All months
      nsub!(/(repeats\s+)?all\s+months/,'every month ')
      nsub!(/(repeats\s+)?all\s+other\+months/, 'every other month ')
      
      # All month
      nsub!(/all\s+month/, 'this month ')
      nsub!(/all\s+next\s+month/, 'next month ')
      
      # "repeats 2nd mon" --> repeats monthly 2nd mon
      # "repeats 2nd mon, 3rd fri, and the last sunday" --> repeats monthly 2nd mon 3rd fri 5th sun
      nsub!(/repeats\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/) { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      
      # "starting at x, ending at y" --> from x to y
      nsub!(/(?:begin|start)(?:s|ing|ning)?\s+(?:at\s+)?#{TIME}\s+(?:and\s+)?end(?:s|ing)?\s+(?:at\s+)#{TIME}/,'from \1 to \2')
      
      # "the x through the y"
      nsub!(/^(?:the\s+)?#{DATE_DD_WITH_SUFFIX}\s+(?:through|to|until)\s+(?:the\s+)?#{DATE_DD_WITH_SUFFIX}$/,'\1 through \2 ')
      
      # "x week(s) away" --> x week(s) from now
      nsub!(/([0-9]+)\s+(day|week|month)s?\s+away/,'\1 \2s from now')
      
      # "x days from now" --> "x days from now"
      # "in 2 weeks|days|months" --> 2 days|weeks|months from now"
      nsub!(/\b(an?|[0-9]+)\s+(day|week|month)s?\s+(?:from\s+now|away)/, '\1 \2 from now')
      nsub!(/in\s+(a|[0-9]+)\s+(week|day|month)s?/, '\1 \2 from now')
      
      # "x minutes|hours from now" --> "in x hours|minutes"
      # "in x hour(s)" --> 11/20/07 at 22:00
      # REDONE, no more calculations
      # "x minutes|hours from now" --> "x hours|minutes from now"
      # "in x hours|minutes --> x hours|minutes from now"
      nsub!(/\b(an?|[0-9]+)\s+(hour|minute)s?\s+(?:from\s+now|away)/, '\1 \2 from now')
      nsub!(/in\s+(an?|[0-9]+)\s+(hour|minute)s?/, '\1 \2 from now')
      
      # Now only
      nsub!(/^(?:\s*)(?:right\s+)?now(?:\s*)$/, '0 minutes from now')
      
      # "a week/month from yesterday|tomorrow" --> 1 week from yesterday|tomorrow
      nsub!(/(?:(?:a|1)\s+)?(week|month)\s+from\s+(yesterday|tomorrow)/,'1 \1 from \2')

      # "a week/month from yesterday|tomorrow" --> 1 week from monday
      nsub!(/(?:(?:a|1)\s+)?(week|month)\s+from\s+#{DAY_OF_WEEK}/,'1 \1 from \2')

      # "every 2|3 days" --> every 2nd|3rd day
      nsub!(/every\s+(2|3)\s+days?/) {|m1| "every " + m1.to_i.ordinalize + " day"}
      
      # "the following" --> following 
      nsub!(/the\s+following/,'following')

      # "friday the 12th to sunday the 14th" --> 12th through 14th
      nsub!(/#{DAY_OF_WEEK}\s+the\s+#{DATE_DD_WITH_SUFFIX}\s+(?:to|through|until)\s+#{DAY_OF_WEEK}\s+the\s+#{DATE_DD_WITH_SUFFIX}/,'\2 through \4')

      # "between 1 and 4" --> from 1 to 4
      nsub!(/between\s+#{TIME}\s+and\s+#{TIME}/,'from \1 to \2')
      
      # "on the 3rd sat of this month" --> "3rd sat this month"
      # "on the 3rd sat and 5th tuesday of this month" --> "3rd sat this month 5th tuesday this month"
      # "on the 3rd sat and sunday of this month" --> "3rd sat this month 3rd sun this month"
      # "on the 2nd and 3rd sat of this month" --> "2nd sat this month 3rd sat this month"
      # This is going to be dicey, I'm going to remove 'the' from the following regexprsns:
      # The 'the' case will be handled AFTER wrapper substitution at end of this method
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:this|of)\s+month/)               { |m1,m2| m2.gsub(/\band\b/,'').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1 this month') }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:this|of)\s+month/)     { |m1,m2| m1.gsub(/\b(and|the)\b/,'').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' this month') }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:this|of)\s+month/) { |m1| m1.gsub(/\b(and|the)\b/,'').gsub(/#{DAY_OF_WEEK}/,'\1 this month') }
      
      # "on the 3rd sat of next month" --> "3rd sat next month"
      # "on the 3rd sat and 5th tuesday of next month" --> "3rd sat next month 5th tuesday next month"
      # "on the 3rd sat and sunday of next month" --> "3rd sat this month 3rd sun next month"
      # "on the 2nd and 3rd sat of next month" --> "2nd sat this month 3rd sat next month"
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?next\s+month/)                { |m1,m2| m2.gsub(/\band\b/,'').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1 next month') }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?next\s+month/)      { |m1,m2| m1.gsub(/\b(and|the)\b/,'').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' next month') }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?next\s+month/)  { |m1| m1.gsub(/\b(and|the)\b/,'').gsub(/#{DAY_OF_WEEK}/,'\1 next month') }
      
      # "on the 3rd sat of nov" --> "3rd sat nov"
      # "on the 3rd sat and 5th tuesday of nov" --> "3rd sat nov 5th tuesday nov            !!!!!!! walking a fine line here, 'nov 5th', but then again the entire nlp walks a pretty fine line
      # "on the 3rd sat and sunday of nov" --> "3rd sat nov 3rd sun nov"
      # "on the 2nd and 3rd sat of nov" --> "2nd sat nov 3rd sat nov"
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR}/)                { |m1,m2,m3| m2.gsub(/\band\b/,'').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1 ' + m3) }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR}/)      { |m1,m2,m3| m1.gsub(/\b(and|the)\b/,'').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' ' + m3) }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR}/)  { |m1,m2| m1.gsub(/\b(and|the)\b/,'').gsub(/#{DAY_OF_WEEK}/,'\1 ' + m2) }
      
      # "on the last day of nov" --> "last day nov"
      nsub!(/(?:\bon\s+)?(?:the\s+)?last\s+day\s+(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR}/,'last day \1')
      # "on the 1st|last day of this|the month" --> "1st|last day this month"
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|last)\s+day\s+(?:of\s+)?(?:this|the)?(?:\s*)month/,'\1 day this month')
      # "on the 1st|last day of next month" --> "1st|last day next month"
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|last)\s+day\s+(?:of\s+)?next\s+month/,'\1 day next month')
      
      # "every other weekend" --> every other sat sun
      nsub!(/every\s+other\s+weekend/,'every other sat sun')
      
      # "this week on mon "--> this mon
      nsub!(/this\s+week\s+(?:on\s+)?#{DAY_OF_WEEK}/,'this \1')
      # "mon of this week " --> this mon
      nsub!(/#{DAY_OF_WEEK}\s+(?:of\s+)?this\s+week/,'this \1')
      
      # "next week on mon "--> next mon
      nsub!(/next\s+week\s+(?:on\s+)?#{DAY_OF_WEEK}/,'next \1')
      # "mon of next week " --> next mon
      nsub!(/#{DAY_OF_WEEK}\s+(?:of\s+)?next\s+week/,'next \1')
      
      # Ordinal this month:
      # this will slip by now
      # the 23rd of this|the month --> 8/23
      # this month on the 23rd --> 8/23
      # REDONE, no date calculations
      # the 23rd of this|the month --> 23rd this month
      # this month on the 23rd --> 23rd this month
      nsub!(/(?:the\s+)?#{DATE_DD}\s+(?:of\s+)?(?:this|the)\s+month/, '\1 this month')
      nsub!(/this\s+month\s+(?:(?:on|the)\s+)?(?:(?:on|the)\s+)?#{DATE_DD}/, '\1 this month')
      
      # Ordinal next month:
      # this will slip by now
      # the 23rd of next month --> 9/23
      # next month on the 23rd --> 9/23
      # REDONE no date calculations
      # the 23rd of next month --> 23rd next month
      # next month on the 23rd --> 23rd next month
      nsub!(/(?:the\s+)?#{DATE_DD}\s+(?:of\s+)?(?:next|the\s+following)\s+month/, '\1 next month')
      nsub!(/(?:next|the\s+following)\s+month\s+(?:(?:on|the)\s+)?(?:(?:on|the)\s+)?#{DATE_DD}/, '\1 next month')
      
      # "for the next 3 days|weeks|months" --> for 3 days|weeks|months
      nsub!(/for\s+(?:the\s+)?(?:next|following)\s+(\d+)\s+(days|weeks|months)/,'for \1 \2')
      
      # This monthname -> monthname
      nsub!(/this\s+#{MONTH_OF_YEAR}/, '\1')
      
      # Until monthname -> through monthname
      # through shouldn't be included here; through and until mean different things, need to fix wrapper terminology
      # "until june --> through june"
      nsub!(/(?:through|until)\s+(?:this\s+)?#{MONTH_OF_YEAR}\s+(?:$|\D)/, 'through \1')
      
      # the week of 1/2 -> week of 1/2
      nsub!(/(the\s+)?week\s+(of|starting)\s+(the\s+)?/, 'week of ')
      
      # the week ending 1/2 -> week through 1/2
      nsub!(/(the\s+)?week\s+(?:ending)\s+/, 'week through ')
      
      # clean up wrapper terminology
      # This should always be at end of pre-process
      nsub!(/(begin(s|ning)?|start(s|ing)?)(\s+(at|on))?/,'start')
      nsub!(/(\bend(s|ing)?|through|until)(\s+(at|on))?/,'through')
      nsub!(/start\s+(?:(?:this|in)\s+)?#{MONTH_OF_YEAR}/,'start \1')
      
      # 'the' cases; what this is all about is if someone enters "first sunday of the month" they mean one date.  But if someone enters "first sunday of the month until december 2nd" they mean recurring
      # Do these actually do ANYTHING anymore?
      # "on the 3rd sat and sunday of the month" --> "repeats monthly 3rd sat 3rd sun"  OR  "3rd sat this month 3rd sun this month"
      if self =~ /(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:the)\s+month/
        if self =~ /(start|through)\s+#{DATE_MM_SLASH_DD}/
          nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:the)\s+month/) {|m1,m2| "repeats monthly " + m2.gsub(/\band\b/,'').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1') }
        else
          nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:the)\s+month/) {|m1,m2| m2.gsub(/\band\b/,'').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1 this month') }
        end
      end
      
      # "on the 2nd and 3rd sat of this month" --> "repeats monthly 2nd sat 3rd sat"  OR  "2nd sat this month 3rd sat this month"
      if self =~ /(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the)\s+month/
        if self =~ /(start|through)\s+#{DATE_MM_SLASH_DD}/
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the)\s+month/) {|m1,m2| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2) }
        else                                                                                                                                     
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the)\s+month/) {|m1,m2| m1.gsub(/\b(and|the)\b/,'').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' this month') }
        end
      end
      
      # "on the 3rd sat and 5th tuesday of this month" --> "repeats monthly 3rd sat 5th tue" OR "3rd sat this month 5th tuesday this month"
      if self =~ /(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the)\s+month/
        if self =~ /(start|through)\s+#{DATE_MM_SLASH_DD}/
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the)\s+month/) { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') }
        else
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the)\s+month/) { |m1| m1.gsub(/\b(and|the)\b/,'').gsub(/#{day_of_week}/,'\1 this month') }
        end
      end
      
      nsub!(/from\s+now\s+(through|to|until)/,'now through')
    end
  end
end

