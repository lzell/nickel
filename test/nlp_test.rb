require 'test/unit'

path = File.expand_path(File.dirname(__FILE__))
require File.join(path, '..', 'lib', 'nickel.rb')
require File.join(path, 'nlp_tests_helper.rb')
include Nickel

# note that ZTime now has the '==' operator, so it won't go through Compare::Objects recursion, meaning we will miss @firm setting, but that is not very important as long as the outcome is correct

class TestDates < Test::Unit::TestCase
  include NLPTestsHelper

  def test__today
    today = Time.local(2008, 8, 25)
    assert_message NLP.new("do something today", today), "do something"
    assert_nlp     NLP.new("do something today", today),  
                   [Occurrence.new(:type => :single, :start_date => ZDate.new("20080825"))]
  end

  def test__today_at_noon
    today = Time.local(2008, 8, 25)
    assert_message NLP.new("there is a movie today at noon", today), "there is a movie"
    assert_nlp     NLP.new("there is a movie today at noon", today), 
                   [Occurrence.new(:type => :single, :start_date => ZDate.new("20080825"), :start_time => ZTime.new("120000"))]
  end

  def test__today_and_tomorrow
    today = Time.local(2008, 8, 25)
    assert_message NLP.new("go to work today and tomorrow", today), "go to work"
    assert_nlp     NLP.new("go to work today and tomorrow", today), 
                   [
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080825")),
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080826"))
                   ]
  end

  def test__oct_5_and_oct_23
    today = Time.local(2008, 8, 25)
    assert_message  NLP.new("Appointments with dentist are on oct 5 and oct 23rd", today), "Appointments with dentist"
    assert_nlp      NLP.new("Appointments with dentist are on oct 5 and oct 23rd", today), 
                    [
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20081005")), 
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20081023"))
                    ]
  end

  def test__today_at_noon_and_tomorrow_at_545am
    today = Time.local(2008, 8, 25)
    assert_message NLP.new("today at noon and tomorrow at 5:45 am there is an office meeting", today), "there is an office meeting"
    assert_message NLP.new("office meeting today at noon and tomorrow at 5:45 am", today), "office meeting"
    assert_nlp     NLP.new("office meeting today at noon and tomorrow at 5:45 am", today),
                   [
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080825"), :start_time => ZTime.new("120000")),
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080826"), :start_time => ZTime.new("054500",:am))
                   ]
  end

  def test__noon_today_and_545am_tomorrow
    today = Time.local(2008, 8, 25)
    assert_message NLP.new("some shit to do at noon today and 545am tomorrow", today), "some shit to do"
    assert_nlp     NLP.new("some shit to do at noon today and 545am tomorrow", today), 
                   [
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080825"), :start_time => ZTime.new("120000")),
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080826"), :start_time => ZTime.new("054500",:am))
                   ]
  end

  def test__tomorrow_and_thursday
    now = Time.local(2008, 2, 29, 12, 34, 56)
    assert_message NLP.new("go to the park tomorrow and thursday with the dog", now), "go to the park with the dog"
    assert_nlp     NLP.new("go to the park tomorrow and thursday with the dog", now), 
                   [
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080301")),
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080306"))
                   ]
  end

  def test__tomorrow_at_1am_and_from_2am_to_5pm_and_thursday_at_1pm
    now = Time.local(2008, 2, 29)
    assert_message NLP.new("how fucking awesome tomorrow at 1am and from 2am to 5pm and thursday at 1pm is this", now), "how fucking awesome is this"
    assert_nlp     NLP.new("how fucking awesome tomorrow at 1am and from 2am to 5pm and thursday at 1pm is this", now), 
                   [
                     Occurrence.new(:type => :single,
                                    :start_date => ZDate.new("20080301"),
                                    :start_time => ZTime.new("010000",:am)),
                                    
                     Occurrence.new(:type => :single,
                                    :start_date => ZDate.new("20080301"),
                                    :start_time => ZTime.new("020000",:am),
                                    :end_time => ZTime.new("050000", :pm)),
                                    
                     Occurrence.new(:type => :single,
                                    :start_date => ZDate.new("20080306"),
                                    :start_time => ZTime.new("010000", :pm))
                   ]
  end

  def test__monday_tuesday_and_wednesday
    now = Time.local(2008, 9, 10)
    assert_message NLP.new("soccer practice monday tuesday and wednesday with susan", now), "soccer practice with susan"
    assert_nlp     NLP.new("soccer practice monday tuesday and wednesday with susan", now), 
                   [
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080915")), 
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080916")), 
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080917"))
                   ]
  end

  def test__monday_and_wednesday_at_4pm
    now = Time.local(2008, 9, 10)
    assert_message NLP.new("monday and wednesday at 4pm I have guitar lessons", now), "I have guitar lessons"
    assert_nlp     NLP.new("monday and wednesday at 4pm I have guitar lessons", now), 
                   [
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080915"), :start_time => ZTime.new("4", :pm)),
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080917"), :start_time => ZTime.new("4", :pm))
                   ]
  end

  def test__4pm_on_monday_and_wednesday
    now = Time.local(2008, 9, 10)
    assert_message NLP.new("meet with so and so 4pm on monday and wednesday", now), "meet with so and so"
    assert_nlp     NLP.new("meet with so and so 4pm on monday and wednesday", now), 
                   [
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080915"), :start_time => ZTime.new("4", :pm)),
                     Occurrence.new(:type => :single, :start_date => ZDate.new("20080917"), :start_time => ZTime.new("4", :pm))
                   ]
  end

  def test__this_sunday
    now = Time.local(2008, 8, 25)
    assert_message NLP.new("flight this sunday on American", now), "flight on American"
    assert_nlp     NLP.new("flight this sunday on American", now), 
                   [Occurrence.new(:type => :single, :start_date => ZDate.new("20080831"))]
  end

  def test__this_sunday_9_dash_5am
    now = Time.local(2007, 11, 25)
    assert_message   NLP.new("Flight to Miami this sunday 9-5am on Jet Blue", now),  "Flight to Miami on Jet Blue"
    assert_nlp       NLP.new("Flight to Miami this sunday 9-5am on Jet Blue", now), 
                     [
                        Occurrence.new(:type => :single, 
                                       :start_date => ZDate.new("20071125"), 
                                       :start_time => ZTime.new("210000"), 
                                       :end_time => ZTime.new("05", :am))
                     ]
  end

  def test__this_sunday_9_dash_5
    now = Time.local(2007, 11, 25)
    assert_message   NLP.new("Go to the park this sunday 9-5", now),  "Go to the park"
    assert_nlp       NLP.new("Go to the park this sunday 9-5", now),
                     [
                       Occurrence.new(:type => :single, 
                                      :start_date => ZDate.new("20071125"),
                                      :start_time => ZTime.new("090000"),
                                      :end_time => ZTime.new("170000"))
                     ]
  end

  def test__today_at_10_11_12_and_1_to_5
    now = Time.local(2008, 9, 10)
    assert_message  NLP.new("movie showings are today at 10, 11, 12, and 1 to 5", now),  "movie showings"
    assert_nlp      NLP.new("movie showings are today at 10, 11, 12, and 1 to 5", now),  
                    [
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("100000")),
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("110000")),
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("120000")),
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("130000"), :end_time => ZTime.new("170000"))
                    ]
  end

  def test__today_at_10_11_12_1
    now = Time.local(2008, 9, 10)
    assert_message  NLP.new("Games today at 10, 11, 12, 1", now),  "Games"
    assert_nlp      NLP.new("Games today at 10, 11, 12, 1", now),  
                    [
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("100000")), 
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("110000")), 
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("120000")), 
                      Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("130000"))
                    ]
  end

  def test__today_from_8_to_4_and_9_to_5
    assert_nlp   NLP.new("today from 8 to 4 and 9 to 5", Time.local(2008, 9, 10)),  
                 [
                   Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("080000"), :end_time => ZTime.new("160000")),
                   Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("090000"), :end_time => ZTime.new("17"))
                 ]
  end

  def test__today_from_9_to_5pm_and_8am_to_4
    assert_nlp   NLP.new("today from 9 to 5pm and 8am to 4", Time.local(2008, 9, 10)), 
                 [
                   Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("080000"), :end_time => ZTime.new("160000")), 
                   Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("090000"), :end_time => ZTime.new("17"))
                 ]
  end

  def test__today_at_11am_2_and_3_and_tomorrow_from_2_to_6pm
    assert_nlp   NLP.new("today at 11am, 2 and 3, and tomorrow from 2 to 6pm", Time.local(2008, 9, 10)),
                 [
                   Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("11", :am)), 
                   Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("2", :pm)), 
                   Occurrence.new(:type => :single, :start_date => ZDate.new("20080910"), :start_time => ZTime.new("3", :pm)), 
                   Occurrence.new(:type => :single, :start_date => ZDate.new("20080911"), :start_time => ZTime.new("2", :pm), :end_time => ZTime.new("6", :pm))
                 ]
  end

  def test__next_monday
    assert_nlp   NLP.new("next monday", Time.local(2008, 10, 27)), [Occurrence.new(:type => :single, :start_date => ZDate.new("20081103"))]
  end

  def test__a_week_from_today
    now = Time.local(2009, 01, 01)
    assert_message  NLP.new("Flight is a week from today", now),  "Flight"
    assert_nlp      NLP.new("Flight is a week from today", now),  [Occurrence.new(:type => :single, :start_date => ZDate.new("20090108"))]
  end

  def test__two_weeks_from_tomorrow
    now = Time.local(2008, 12, 24)
    assert_message  NLP.new("Bill is due two weeks from tomorrow", now),  "Bill is due"
    assert_nlp      NLP.new("Bill is due two weeks from tomorrow", now),  [Occurrence.new(:type => :single, :start_date => ZDate.new("20090108"))]
  end

  def test__two_months_from_now
    now = Time.local(2008, 12, 24)
    assert_message  NLP.new("Tryouts are two months from now", now),  "Tryouts"
    assert_nlp      NLP.new("Tryouts are two months from now", now),  [Occurrence.new(:type => :single, :start_date => ZDate.new("20090224"))]
  end

  def test__october_2nd
    now = Time.local(2008, 1, 30)
    assert_message  NLP.new("baseball game is on october second", now),   "baseball game"
    assert_message  NLP.new("baseball game is on 10/2", now),             "baseball game"
    assert_message  NLP.new("baseball game is on 10/2/08", now),          "baseball game"
    assert_message  NLP.new("baseball game is on 10/2/2008", now),        "baseball game"
    assert_message  NLP.new("baseball game is on october 2nd 08", now),   "baseball game"
    assert_message  NLP.new("baseball game is on october 2nd 2008", now), "baseball game"
    assert_nlp      NLP.new("baseball game is on october second", now),   [Occurrence.new(:type => :single, :start_date => ZDate.new("20081002"))]
    assert_nlp      NLP.new("baseball game is on 10/2", now),             [Occurrence.new(:type => :single, :start_date => ZDate.new("20081002"))]
    assert_nlp      NLP.new("baseball game is on 10/2/08", now),          [Occurrence.new(:type => :single, :start_date => ZDate.new("20081002"))]
    assert_nlp      NLP.new("baseball game is on 10/2/2008", now),        [Occurrence.new(:type => :single, :start_date => ZDate.new("20081002"))]
    assert_nlp      NLP.new("baseball game is on october 2nd 08", now),   [Occurrence.new(:type => :single, :start_date => ZDate.new("20081002"))]
    assert_nlp      NLP.new("baseball game is on october 2nd 2008", now), [Occurrence.new(:type => :single, :start_date => ZDate.new("20081002"))]
  end

  def test__last_monday_this_month
    now = Time.local(2008, 8, 25)
    assert_nlp   NLP.new("last monday this month", now),         [Occurrence.new(:type => :single, :start_date => ZDate.new("20080825"))]
    assert_nlp   NLP.new("the last monday of this month", now),  [Occurrence.new(:type => :single, :start_date => ZDate.new("20080825"))]
  end

  def test__third_monday_next_month
    now = Time.local(2008, 8, 25)
    assert_nlp   NLP.new("third monday next month", now),      [Occurrence.new(:type => :single, :start_date => ZDate.new("20080915"))]
    assert_nlp   NLP.new("the third monday next month", now),  [Occurrence.new(:type => :single, :start_date => ZDate.new("20080915"))]
  end

  def test__the_28th
    now = Time.local(2010, 03, 20)
    assert_message  NLP.new("baseball game is on the twentyeighth", now),        "baseball game"
    assert_message  NLP.new("baseball game is on the 28th of this month", now),  "baseball game"
    assert_nlp   NLP.new("the twentyeigth", now),         [Occurrence.new(:type => :single, :start_date => ZDate.new("20100328"))]
    assert_nlp   NLP.new("28th", now),                    [Occurrence.new(:type => :single, :start_date => ZDate.new("20100328"))]
    assert_nlp   NLP.new("28", now),                      [Occurrence.new(:type => :single, :start_date => ZDate.new("20100328"))]
    assert_nlp   NLP.new("the 28th of this month", now),  [Occurrence.new(:type => :single, :start_date => ZDate.new("20100328"))]
    assert_nlp   NLP.new("28th of this month", now),      [Occurrence.new(:type => :single, :start_date => ZDate.new("20100328"))]
    assert_nlp   NLP.new("the 28th this month", now),     [Occurrence.new(:type => :single, :start_date => ZDate.new("20100328"))]
  end

  def test__the_28th_next_month
    now = Time.local(2008, 12, 31, 23, 05, 59)
    assert_nlp   NLP.new("next month 28th", now),         [Occurrence.new(:type => :single, :start_date => ZDate.new("20090128"))]
    assert_nlp   NLP.new("28th next month", now),         [Occurrence.new(:type => :single, :start_date => ZDate.new("20090128"))]
    assert_nlp   NLP.new("the 28th next month", now),     [Occurrence.new(:type => :single, :start_date => ZDate.new("20090128"))]
    assert_nlp   NLP.new("28th of next month", now),      [Occurrence.new(:type => :single, :start_date => ZDate.new("20090128"))]
    assert_nlp   NLP.new("the 28th of next month", now),  [Occurrence.new(:type => :single, :start_date => ZDate.new("20090128"))]
  end

  def test__in_5_days_weeks_months
    now = Time.local(2008, 9, 11)
    assert_nlp    NLP.new("5 days from now", now),                [Occurrence.new(:type => :single, :start_date => ZDate.new("20080916"))]
    assert_nlp    NLP.new("in 5 days", Time.local(2008, 9, 30)),  [Occurrence.new(:type => :single, :start_date => ZDate.new("20081005"))]
    assert_nlp    NLP.new("5 weeks from now", now),               [Occurrence.new(:type => :single, :start_date => ZDate.new("20081016"))]
    assert_nlp    NLP.new("in 5 weeks", now),                     [Occurrence.new(:type => :single, :start_date => ZDate.new("20081016"))]
    assert_nlp    NLP.new("5 months from now", now),              [Occurrence.new(:type => :single, :start_date => ZDate.new("20090211"))]
    assert_nlp    NLP.new("in 5 months", now),                    [Occurrence.new(:type => :single, :start_date => ZDate.new("20090211"))]
  end

  def test__in_5_minutes_hours
    now = Time.local(2008, 9, 11)

    assert_nlp    NLP.new("5 minutes from now", now), [Occurrence.new(:type => :single, 
                                                                      :start_date => ZDate.new("20080911"),
                                                                      :start_time => ZTime.new("000500"))]

    assert_nlp    NLP.new("5 hours from now", now),   [Occurrence.new(:type => :single,
                                                                      :start_date => ZDate.new("20080911"),
                                                                      :start_time => ZTime.new("050000"))]

    assert_nlp    NLP.new("24 hours from now", now),  [Occurrence.new(:type => :single,
                                                                      :start_date => ZDate.new("20080912"),
                                                                      :start_time => ZTime.new("000000"))]
                                                                      
    assert_nlp    NLP.new("in 5 minutes", now),       [Occurrence.new(:type => :single,
                                                                      :start_date => ZDate.new("20080911"),
                                                                      :start_time => ZTime.new("000500"))]
                                                                      
    assert_nlp    NLP.new("in 5 hours", now),         [Occurrence.new(:type => :single,
                                                                      :start_date => ZDate.new("20080911"),
                                                                      :start_time => ZTime.new("050000"))]
  end
  
  def test__tomorrow_through_sunday
     assert_nlp  NLP.new("tomorrow through sunday", Time.local(2008, 9, 18)),  [Occurrence.new(:type => :daily,
                                                                                                :start_date => ZDate.new("20080919"),
                                                                                                :end_date => ZDate.new("20080921"),
                                                                                                :interval => 1)]
  end
  
  def test__tomorrow_through_sunday_from_9_to_5
    assert_nlp  NLP.new("tomorrow through sunday from 9 to 5", Time.local(2008, 9, 18)),  
                [
                  Occurrence.new(:type => :daily,
                                 :start_date => ZDate.new("20080919"),
                                 :end_date => ZDate.new("20080921"),
                                 :start_time => ZTime.new("09"),
                                 :end_time => ZTime.new("17"),
                                 :interval => 1)
                ]
  end

  def test__9_to_5_tomorrow_through_sunday
    assert_nlp  NLP.new("9 to 5 tomorrow through sunday", Time.local(2008, 9, 18)),
                [
                  Occurrence.new(:type => :daily,
                                 :start_date => ZDate.new("20080919"),
                                 :end_date => ZDate.new("20080921"),
                                 :start_time => ZTime.new("09"),
                                 :end_time => ZTime.new("17"),
                                 :interval => 1)
                ]
  end

  def test__october_2nd_through_5th    
    now = Time.local(2008, 9, 18)
    
    assert_nlp  NLP.new("october 2nd through 5th", now), [ Occurrence.new(:type => :daily,
                                                                          :start_date => ZDate.new("20081002"),
                                                                          :end_date => ZDate.new("20081005"),
                                                                          :interval => 1) ]
                                                                          
    assert_nlp  NLP.new("october 2nd through october 5th", now), [ Occurrence.new(:type => :daily,
                                                                                  :start_date => ZDate.new("20081002"),
                                                                                  :end_date => ZDate.new("20081005"),
                                                                                  :interval => 1) ]

    assert_nlp  NLP.new("10/2 to 10/5", now), [ Occurrence.new(:type => :daily,
                                                               :start_date => ZDate.new("20081002"),
                                                               :end_date => ZDate.new("20081005"),
                                                               :interval => 1) ]
                                                               
    assert_nlp  NLP.new("oct 2 until 5", now), [ Occurrence.new(:type => :daily,
                                                                :start_date => ZDate.new("20081002"),
                                                                :end_date => ZDate.new("20081005"),
                                                                :interval => 1) ]
                                                                
    assert_nlp  NLP.new("oct 2 until oct 5", now), [ Occurrence.new(:type => :daily,
                                                                    :start_date => ZDate.new("20081002"), 
                                                                    :end_date => ZDate.new("20081005"), 
                                                                    :interval => 1) ]
                                                                    
    assert_nlp  NLP.new("oct 2-oct 5", now), [ Occurrence.new(:type => :daily,
                                                              :start_date => ZDate.new("20081002"),
                                                              :end_date => ZDate.new("20081005"),
                                                              :interval => 1) ]
                                                              
    assert_nlp  NLP.new("october 2-5", now), [ Occurrence.new(:type => :daily,
                                                              :start_date => ZDate.new("20081002"),
                                                              :end_date => ZDate.new("20081005"),
                                                              :interval => 1) ]
                                                              
    assert_nlp  NLP.new("october 2nd-5th", now), [ Occurrence.new(:type => :daily,
                                                                  :start_date => ZDate.new("20081002"), 
                                                                  :end_date => ZDate.new("20081005"), 
                                                                  :interval => 1) ]
                                                                  
    assert_nlp  NLP.new("october 2nd-5th from 9 to 5am", now), [ Occurrence.new(:type => :daily,
                                                                                :start_date => ZDate.new("20081002"), 
                                                                                :end_date => ZDate.new("20081005"),
                                                                                :interval => 1,
                                                                                :start_time => ZTime.new("21"),
                                                                                :end_time => ZTime.new("05")) ]

    assert_nlp  NLP.new("october 2nd-5th every day from 9 to 5am", now), [ Occurrence.new(:type => :daily,
                                                                                          :start_date => ZDate.new("20081002"), 
                                                                                          :end_date => ZDate.new("20081005"), 
                                                                                          :interval => 1, 
                                                                                          :start_time => ZTime.new("21"), 
                                                                                          :end_time => ZTime.new("05")) ]
  end

	def test__january_1st_through_february_15th
    now = Time.local(2013, 1, 25)
		assert_nlp  NLP.new("january 1 - february 15", now), [ Occurrence.new(:type => :daily,
																															:start_date => ZDate.new("20130101"), 
																															:end_date => ZDate.new("20130215"),
																															:interval => 1) ]
	end

	def test__january_1st_from_1PM_to_5_AM
    now = Time.local(2013, 1, 25)
		assert_nlp  NLP.new("january 1 from 1PM to 5AM", now), [ Occurrence.new(:type => :daily,
																															:start_date => ZDate.new("20130101"), 
																															:end_date => ZDate.new("20130102"),
																															:start_time => ZTime.new("13"),
																															:end_time => ZTime.new("5"),
																															:interval => 1) ]
	end

	def test__tuesday_january_1st_through_friday_february_15th_2013
    now = Time.local(2008, 1, 25)
		assert_nlp  NLP.new("tuesday, january 1st - friday, february 15, 2013", now), [ Occurrence.new(:type => :daily,
																															:start_date => ZDate.new("20130101"), 
																															:end_date => ZDate.new("20130215"),
																															:interval => 1) ]
	end

	def test__tuesday_january_1st_2013_through_friday_february_15th_2013
    now = Time.local(2008, 1, 25)
		assert_nlp  NLP.new("tuesday, january 1, 2013 - friday, february 15, 2013", now), [ Occurrence.new(:type => :daily,
																															:start_date => ZDate.new("20130101"), 
																															:end_date => ZDate.new("20130215"),
																															:interval => 1) ]
	end

	def test__tuesday_january_1st_2013_at_10AM_through_friday_february_15th_2013_at_7PM
    now = Time.local(2008, 1, 25)
		assert_nlp  NLP.new("tuesday, january 1, 2013 at 10AM - friday, february 15, 2013 at 7PM", now), [ Occurrence.new(:type => :daily,
																															:start_time => ZTime.new("10"),
																															:start_date => ZDate.new("20130101"), 
																															:end_date => ZDate.new("20130215"),
																															:end_time => ZTime.new("19"),
																															:interval => 1) ]
	end

  def test__every_monday
    assert_nlp  NLP.new("every monday", Time.local(2008, 9, 18)), [Occurrence.new(:type => :weekly,
                                                                                   :day_of_week => 0,
                                                                                   :interval => 1,
                                                                                   :start_date => ZDate.new("20080922"))]
  end

  def test__every_monday_and_wednesday
    assert_nlp  NLP.new("every monday and wednesday", Time.local(2008, 9, 18)), 
                [
                  Occurrence.new(:type => :weekly, :day_of_week => 0, :interval => 1, :start_date => ZDate.new("20080922")),
                  Occurrence.new(:type => :weekly, :day_of_week => 2, :interval => 1, :start_date => ZDate.new("20080924"))
                ]
  end

  def test__every_other_monday_and_wednesday
    assert_nlp  NLP.new("every other monday and wednesday", Time.local(2008, 9, 18)), 
                [
                  Occurrence.new(:type => :weekly, :day_of_week => 0, :interval => 2, :start_date => ZDate.new("20080922")), 
                  Occurrence.new(:type => :weekly, :day_of_week => 2, :interval => 2, :start_date => ZDate.new("20080924"))
                ]
  end

  # Fail here!
  # def test__every_monday_at_2pm_and_wednesday_at_4pm
  #   assert_nlp  NLP.new("every monday at 2pm and wednesday at 4pm", Time.local(2008, 9, 18)),
  #               [
  #                 Occurrence.new(:type => :weekly, :day_of_week => 0, :interval => 1, :start_date => ZDate.new("20080922"), :start_time => ZTime.new("2", :pm)), 
  #                 Occurrence.new(:type => :weekly, :day_of_week => 2, :interval => 1, :start_date => ZDate.new("20080924"), :start_time => ZTime.new("4", :pm))
  #               ]
  # end
  
  def test__every_monday_at_2pm_and_every_wednesday_at_4pm
    assert_nlp  NLP.new("every monday at 2pm and every wednesday at 4pm", Time.local(2008, 9, 18)),
                [
                  Occurrence.new(:type => :weekly, :day_of_week => 0, :interval => 1, :start_time => ZTime.new("2", :pm), :start_date => ZDate.new("20080922")), 
                  Occurrence.new(:type => :weekly, :day_of_week => 2, :interval => 1, :start_time => ZTime.new("4", :pm), :start_date => ZDate.new("20080924"))
                ]
  end

  def test__every_monday_every_wednesday
    assert_nlp  NLP.new("every monday every wednesday", Time.local(2008, 9, 18)),
                [
                  Occurrence.new(:type => :weekly, :day_of_week => 0, :interval => 1, :start_date => ZDate.new("20080922")), 
                  Occurrence.new(:type => :weekly, :day_of_week => 2, :interval => 1, :start_date => ZDate.new("20080924"))
                ]
  end

  def test__the_22nd_of_every_month
    assert_nlp  NLP.new("the 22nd of every month", Time.local(2008, 9, 18)),
                [
                  Occurrence.new(:type => :datemonthly, :date_of_month => 22, :interval => 1, :start_date => ZDate.new("20080922"))
                ]
  end

  def test__the_first_friday_of_every_month
    assert_nlp  NLP.new("the first friday of every month", Time.local(2008, 9, 18)), 
                [
                  Occurrence.new(:type => :daymonthly, :week_of_month => 1, :day_of_week => 4, :interval => 1, :start_date => ZDate.new("20081003"))
                ]
  end

  def test__the_second_tuesday_of_every_month_at_5pm
    assert_nlp  NLP.new("the second tuesday of every month at 5pm", Time.local(2008, 9, 24)),
                [
                  Occurrence.new(:type => :daymonthly,
                                 :week_of_month => 2, 
                                 :day_of_week => 1, 
                                 :interval => 1, 
                                 :start_date => ZDate.new("20081014"), 
                                 :start_time => ZTime.new("5", :pm))
                ]
  end

  def test__the_first_tuesday_of_every_month_at_4pm_and_5pm_and_the_second_tuesday_of_every_month_at_5pm
    now = Time.local(2008, 9, 24)
    assert_nlp  NLP.new("the first tuesday of every month at 4pm and 5pm, the second tuesday of every month at 5pm", now), 
                [
                  Occurrence.new(:type => :daymonthly,
                                 :week_of_month => 1,
                                 :day_of_week => 1,
                                 :interval => 1, 
                                 :start_date => ZDate.new("20081007"), 
                                 :start_time => ZTime.new("4", :pm)), 
                                 
                  Occurrence.new(:type => :daymonthly,
                                 :week_of_month => 1,
                                 :day_of_week => 1, 
                                 :interval => 1, 
                                 :start_date => ZDate.new("20081007"), 
                                 :start_time => ZTime.new("5", :pm)),
                                  
                  Occurrence.new(:type => :daymonthly,
                                 :week_of_month => 2, 
                                 :day_of_week => 1, 
                                 :interval => 1, 
                                 :start_date => ZDate.new("20081014"), 
                                 :start_time => ZTime.new("5", :pm))
              ]
  end

  def test_every_sunday_in_december
    assert_nlp  NLP.new("every sunday in december", Time.local(2008, 9, 24)),
                [
                  Occurrence.new(:type => :weekly,
                                 :day_of_week => 6, 
                                 :interval => 1, 
                                 :start_date => ZDate.new("20081207"), 
                                 :end_date => ZDate.new("20081228"))
                ]
  end

  def test_every_monday_until_december
    assert_nlp  NLP.new("every monday until december", Time.local(2008, 9, 24)), 
                [
                  Occurrence.new(:type => :weekly,
                                 :day_of_week => 0, 
                                 :interval => 1, 
                                 :start_date => ZDate.new("20080929"), 
                                 :end_date => ZDate.new("20081124"))
                ]
  end

  def test_every_monday_next_month
    assert_nlp  NLP.new("every monday next month", Time.local(2008, 9, 24)), 
                [
                  Occurrence.new(:type => :weekly,
                                 :day_of_week => 0, 
                                 :interval => 1, 
                                 :start_date => ZDate.new("20081006"), 
                                 :end_date => ZDate.new("20081027"))
                ]
  end

  def test_everyday_next_month
    assert_nlp  NLP.new("everyday next month", Time.local(2008, 12, 24)), 
                [
                  Occurrence.new(:type => :daily, :interval => 1, :start_date => ZDate.new("20090101"), :end_date => ZDate.new("20090131"))
                ]
  end

  def test_in_the_next_two_days
    assert_nlp  NLP.new("in the next two days", Time.local(2007, 12, 29)), 
                [
                  Occurrence.new(:type => :daily, :interval => 1, :start_date => ZDate.new("20071229"), :end_date => ZDate.new("20071231"))
                ]
  end

  def test_for_three_days
    assert_nlp  NLP.new("for three days", Time.local(2007, 12, 29)), 
                [
                  Occurrence.new(:type => :daily, :interval => 1, :start_date => ZDate.new("20071229"), :end_date => ZDate.new("20080101"))
                ]
                
    assert_nlp  NLP.new("for the next three days", Time.local(2007, 12, 29)),
                [
                  Occurrence.new(:type => :daily, :interval => 1, :start_date => ZDate.new("20071229"), :end_date => ZDate.new("20080101"))
                ]
  end

  def test_for_the_next_1_day
    now = Time.local(2007, 12, 29)
    assert_message  NLP.new("blah for the next 1 day", now), "blah"
    assert_nlp      NLP.new("blah for the next 1 day", now), 
                    [
                      Occurrence.new(:type => :daily, :interval => 1, :start_date => ZDate.new("20071229"), :end_date => ZDate.new("20071230"))
                    ]
  end

  def test_this_week
    now = Time.local(2008, 9, 25)
    assert_nlp  NLP.new("this week", now), 
                [
                  Occurrence.new(:type => :daily, :interval => 1, :start_date => ZDate.new("20080925"), :end_date => ZDate.new("20081002"))
                ]
                
    assert_nlp  NLP.new("every day this week", now), 
                [
                  Occurrence.new(:type => :daily, :interval => 1, :start_date => ZDate.new("20080925"), :end_date => ZDate.new("20081002"))
                ]
  end

  def test_next_week
    now = Time.local(2008, 9, 25)
    assert_nlp  NLP.new("next week", now), 
      [
        Occurrence.new(:type => :daily, :interval => 1, :start_date => ZDate.new("20081002"), :end_date => ZDate.new("20081009"))
      ]
      
    assert_nlp  NLP.new("every day next week", now), 
      [
        Occurrence.new(:type => :daily, :interval => 1, :start_date => ZDate.new("20081002"), :end_date => ZDate.new("20081009"))
      ]
  end

  def test_go_to_the_park_tomorrow_and_also_on_thursday_with_the_dog
    now = Time.local(2008, 10, 28)

    assert_message  NLP.new("go to the park tomorrow and also on thursday with the dog", now), "go to the park with the dog"
    assert_message  NLP.new("go to the park tomorrow and thursday with the dog", now),         "go to the park with the dog"
    assert_message  NLP.new("go to the park tomorrow and also thursday with the dog", now),    "go to the park with the dog"
    assert_message  NLP.new("go to the park tomorrow and on thursday with the dog", now),      "go to the park with the dog"
    assert_message  NLP.new("go to the park tomorrow, thursday with the dog", now),            "go to the park with the dog"

    assert_nlp  NLP.new("go to the park tomorrow and also on thursday with the dog", now), 
                [
                  Occurrence.new(:type => :single, :start_date => ZDate.new("20081029")), 
                  Occurrence.new(:type => :single, :start_date => ZDate.new("20081030"))
                ]
  end

  def test_pick_up_groceries_tomorrow_and_also_the_kids
    now = Time.local(2008, 10, 28)
    assert_message  NLP.new("pick up groceries tomorrow and also the kids", now), "pick up groceries and also the kids"
    assert_message  NLP.new("pick up groceries tomorrow and the kids", now),      "pick up groceries and the kids"
    assert_nlp      NLP.new("pick up groceries tomorrow and also the kids", now), [Occurrence.new(:type => :single, :start_date => ZDate.new("20081029"))]
  end

  def test_all_month
    NLP::use_date_correction = false
    
    assert_nlp  NLP.new("all month", Time.local(2008, 10, 05)), 
                [
                  Occurrence.new(:type => :daily,
                                 :start_date => ZDate.new("20081001"),
                                 :end_date => ZDate.new("20081031"),
                                 :interval => 1)
                ]
                
    NLP::use_date_correction = true
  end

  def test_all_month_date_corrected
    NLP::use_date_correction = true
    assert_nlp  NLP.new("all month", Time.local(2008, 10, 05)), 
                [
                  Occurrence.new(:type => :daily,
                                 :start_date => ZDate.new("20081005"),
                                 :end_date => ZDate.new("20081031"),
                                 :interval => 1)
                ]
  end

  def test_week_of_jan_2nd
    assert_nlp  NLP.new("the week of jan 2nd", Time.local(2008, 12, 21)),
                [
                  Occurrence.new(:type => :daily,
                                 :start_date => ZDate.new("20090102"), 
                                 :end_date => ZDate.new("20090109"),
                                 :interval => 1)
                ]
  end

  def test_week_ending_jan_2nd
    assert_nlp  NLP.new("the week ending jan 2nd", Time.local(2008, 12, 21)), 
                [
                  Occurrence.new(:type => :daily,
                                 :start_date => ZDate.new("20081226"),
                                 :end_date => ZDate.new("20090102"), 
                                 :interval => 1)
                ]
  end

  def test_week_of_the_22nd
    assert_nlp  NLP.new("the week of the 22nd", Time.local(2008, 12, 21)),
                [
                  Occurrence.new(:type => :daily,
                                 :start_date => ZDate.new("20081222"),
                                 :end_date => ZDate.new("20081229"),
                                 :interval => 1)
                ]
  end
  
# ------------------------------------------------ Tests using date correction start here ------------------------------------------------------
# -------------------------------------------- THESE WILL FAIL IF 'NLPv2.use_date_correction' IS OFF -------------------------------------------------
  def test_dates_across_a_year_boundary
    now = Time.local(2008, 11, 30)
    NLP::use_date_correction = true
    assert_message  NLP.new("do something on january first", now), "do something"
    assert_nlp  NLP.new("do something on january first", now), [Occurrence.new(:type => :single, :start_date => ZDate.new("20090101"))]
  end

  def test_the_first_of_the_month
    now = Time.local(2008, 11, 30)
    NLP::use_date_correction = true
    assert_nlp  NLP.new("on the first of the month, go to the museum", now), [Occurrence.new(:type => :single, :start_date => ZDate.new("20081201"))]
  end
# ------------------------------------------------ Tests using date correction end here --------------------------------------------------------  
  
  # tests to write
  # this monday wed fri sat
  # next monday wed fri sat
  # monday wed fri sat
  
# --------------------------------------------------- NLPv1 tests start here -------------------------------------------------------------
  def test__october_2nd_2009
    assert_nlp NLP.new("october 2nd, 2009", Time.local(2008, 1, 01)), [Occurrence.new(:type => :single, :start_date => ZDate.new("20091002"))]
  end

  def test__april_29_5_to_8_pm
    now = Time.local(2008, 3, 30)
    assert_nlp NLP.new("April 29, 5-8pm", now), 
      [Occurrence.new(
        :type => :single, 
        :start_date => ZDate.new("20080429"), 
        :start_time => ZTime.new("5", :pm),
        :end_time => ZTime.new("8", :pm))]
  end

  def test__the_first_of_each_month
    assert_nlp NLP.new("the first of each month", Time.local(2008, 1, 01)), 
               [
                 Occurrence.new(:type => :datemonthly,
                                :start_date => ZDate.new("20080101"),
                                :interval => 1,
                                :date_of_month => 1)
               ]
               
    assert_nlp NLP.new("the first of each month", Time.local(2009, 02, 15)),
               [
                 Occurrence.new(:type => :datemonthly,
                                :start_date => ZDate.new("20090301"), 
                                :interval => 1, 
                                :date_of_month => 1)
               ]
  end

  def test__every_sunday
    assert_nlp NLP.new("every sunday", Time.local(2008, 12, 30)), 
               [
                 Occurrence.new(:type => :weekly,
                                :start_date => ZDate.new("20090104"),
                                :interval => 1,
                                :day_of_week => 6)
               ]
  end

  def test__every_month_on_the_22nd_at_2pm
    assert_nlp NLP.new("every month on the 22nd at 2pm", Time.local(2008, 12, 30)),
               [
                 Occurrence.new(:type => :datemonthly,
                                :start_date => ZDate.new("20090122"), 
                                :interval => 1, 
                                :date_of_month => 22, 
                                :start_time => ZTime.new("2", :pm))
               ]
  end

  def test_every_other_saturday_at_noon
    assert_nlp NLP.new("every other saturday at noon", Time.local(2008, 12, 30)), 
               [
                 Occurrence.new(:type => :weekly,
                                :start_date => ZDate.new("20090103"),
                                :interval => 2, 
                                :day_of_week => 5, 
                                :start_time => ZTime.new("12", :pm))
               ]
  end

  def test_every_day_at_midnight
    assert_nlp NLP.new("every day at midnight", Time.local(2008, 12, 30)), 
               [
                 Occurrence.new(:type => :daily,
                                :start_date => ZDate.new("20081230"),
                                :interval => 1,
                                :start_time => ZTime.new("12", :am))
               ]
  end

  def test_daily_from_noon_to_midnight
    assert_nlp NLP.new("daily from noon to midnight", Time.local(2008, 12, 30)), 
               [
                 Occurrence.new(:type => :daily,
                                :start_date => ZDate.new("20081230"),
                                :interval => 1,
                                :start_time => ZTime.new("12", :pm),
                                :end_time => ZTime.new("12", :am))
               ]
  end

  def test_the_last_tuesday_of_every_month
    assert_nlp NLP.new("the last tuesday of every month, starts at 9am", Time.local(2008, 12, 30)),
               [
                 Occurrence.new(:type => :daymonthly,
                                :start_date => ZDate.new("20081230"),
                                :start_time => ZTime.new("9", :am),
                                :interval => 1,
                                :week_of_month => -1,
                                :day_of_week => 1)
               ]
  end

  def test_one_week_from_today
    assert_nlp NLP.new("one week from today", Time.local(2008, 12, 30)), 
               [
                 Occurrence.new(:type => :single, :start_date => ZDate.new("20090106"))
               ]
  end

  def test_every_other_day_at_245am
    assert_nlp NLP.new("every other day at 2:45am", Time.local(2008, 12, 30)), 
               [
                 Occurrence.new(:type => :daily,
                                :start_date => ZDate.new("20081230"),
                                :start_time => ZTime.new("0245", :am),
                                :interval => 2)
               ]
  end

  def test_every_other_day_at_245am_starting_tomorrow
    assert_nlp NLP.new("every other day at 2:45am starting tomorrow", Time.local(2008, 12, 30)), 
               [
                 Occurrence.new(:type => :daily,
                                :start_date => ZDate.new("20081231"),
                                :start_time => ZTime.new("0245", :am),
                                :interval => 2)
               ]
  end
end

