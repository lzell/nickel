# Ruby Nickel Library 
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]

module Nickel
  module NLPQueryConstants
    DATE_DD                          = %r{\b((?:0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)?)\b}
    DATE_DD_NB_ON_SUFFIX             = %r{\b(0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)?\b}
    DATE_DD_NB                       = %r{\b(?:0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)?\b}    
    DATE_DD_WITH_SUFFIX              = %r{\b((?:0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th))\b}
    DATE_DD_WITHOUT_SUFFIX           = %r{\b(0?[1-9]|[12][0-9]|3[01])\b}
    DATE_DD_WITH_SUFFIX_NB           = %r{\b(?:0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)\b}
    DATE_DD_WITHOUT_SUFFIX_NB        = %r{\b(?:0?[1-9]|[12][0-9]|3[01])\b}
    DATE_DD_WITH_SUFFIX_NB_ON_SUFFIX = %r{\b(0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)\b}
    DATE_MM_SLASH_DD                 = %r{\b(?:0?[1-9]|[1][0-2])\/(?:0?[1-9]|[12][0-9]|3[01])}
    DAY_OF_WEEK                      = %r{\b(mon|tue|wed|thu|thurs|fri|sat|sun)\b}
    DAY_OF_WEEK_NB                   = %r{\b(?:mon|tue|wed|thu|thurs|fri|sat|sun)\b}        #no backreference
    MONTH_OF_YEAR                    = %r{\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b}
    MONTH_OF_YEAR_NB                 = %r{\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b}
    TIME_24HR                        = %r{[01]?[0-9]|2[0-3]:[0-5][0-9]}
    TIME_12HR                        = %r{(?:0?[1-9]|1[0-2])(?::[0-5][0-9])?(?:am|pm)?}   # note 12 passes, as does 12:00
    TIME                             = %r{(#{TIME_12HR}|#{TIME_24HR})}      
    YEAR                             = %r{((?:20)?0[789](?:\s|\n)|(?:20)[1-9][0-9])}
    WEEK_OF_MONTH                    = %r{(1st|2nd|3rd|4th|5th)}
  end
end
