require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'nickel', 'ruby_ext', 'to_s2.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'nickel', 'zdate.rb'))

include Nickel

class ZDateTest < Test::Unit::TestCase

  def test_get_next_date_from_date_of_month
    d1 = ZDate.new('20090927')
    assert_equal ZDate.new('20090928'), d1.get_next_date_from_date_of_month(28)
    assert_equal ZDate.new('20091005'), d1.get_next_date_from_date_of_month(5)
    assert_equal nil, d1.get_next_date_from_date_of_month(31)
  end
  
  # def test_get_date_from_day_and_week_of_month
  #   d1 = ZDate.new('20090927')
  #   assert_equal ZDate.new('20090930'), d1.get_date_from_day_and_week_of_month(Z::WED, -1)
  #   assert_equal ZDate.new('20090930'), d1.get_date_from_day_and_week_of_month(Z::WED, 5)
  #   # there is no 5th thursday this sept
  #   assert_equal nil, d1.get_date_from_day_and_week_of_month(Z::THU, 5)
  # end
  
  def test_diff_in_days_to_this
    d1 = ZDate.new('20090927')
    assert_equal 0, d1.diff_in_days_to_this(ZDate::SUN)
    assert_equal 1, d1.diff_in_days_to_this(ZDate::MON)
    assert_equal 2, d1.diff_in_days_to_this(ZDate::TUE)
    assert_equal 3, d1.diff_in_days_to_this(ZDate::WED)
    assert_equal 4, d1.diff_in_days_to_this(ZDate::THU)
    assert_equal 5, d1.diff_in_days_to_this(ZDate::FRI)
    assert_equal 6, d1.diff_in_days_to_this(ZDate::SAT)

    d2 = ZDate.new('20090930')
    assert_equal 0, d2.diff_in_days_to_this(ZDate::WED)
    assert_equal 1, d2.diff_in_days_to_this(ZDate::THU)
    assert_equal 2, d2.diff_in_days_to_this(ZDate::FRI)
    assert_equal 3, d2.diff_in_days_to_this(ZDate::SAT)
    assert_equal 4, d2.diff_in_days_to_this(ZDate::SUN)
    assert_equal 5, d2.diff_in_days_to_this(ZDate::MON)
    assert_equal 6, d2.diff_in_days_to_this(ZDate::TUE)
  end

  def test_to_date
    date = ZDate.new('20090927')
    assert_equal Date.new(2009, 9, 27), date.to_date
  end
end
