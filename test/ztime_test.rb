require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'nickel', 'ruby_ext', 'to_s2.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'nickel', 'ztime.rb'))

include Nickel

class ZTimeTest < Test::Unit::TestCase

  def test_12_to_12am
    t1 = ZTime.new("1200")
    t2 = ZTime.new("1200", :am)
    t1_after_modify = t1.dup    # t1 should not change
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_12pm_to_12
    t1 = ZTime.new("1200", :pm)
    t2 = ZTime.new("1200")
    t2_after_modify = ZTime.new("1200", :am)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_12_to_12pm
    t1 = ZTime.new("1200")
    t2 = ZTime.new("1200", :pm)
    t1_after_modify = ZTime.new("12", :am)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_12am_to_12
    t1 = ZTime.new("1200", :am)
    t2 = ZTime.new("1200")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_1_to_2am
    t1 = ZTime.new("1")
    t2 = ZTime.new("2", :am)
    t1_after_modify = t1.dup    # t1 should not change
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1am_to_2
    t1 = ZTime.new("1", :am)
    t2 = ZTime.new("2")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_10_to_11pm
    t1 = ZTime.new("10")
    t2 = ZTime.new("11", :pm)
    t1_after_modify = ZTime.new("10", :pm)    # should really be 10pm
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_10pm_to_11
    t1 = ZTime.new("10", :pm)
    t2 = ZTime.new("11")
    t2_after_modify = ZTime.new("11", :pm)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_8_to_12pm
    t1 = ZTime.new("8")
    t2 = ZTime.new("12", :pm)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_8am_to_12
    t1 = ZTime.new("8", :am)
    t2 = ZTime.new("12")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_830_to_835am
    t1 = ZTime.new("0830")
    t2 = ZTime.new("0835", :am)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_830am_to_835
    t1 = ZTime.new("0830", :am)
    t2 = ZTime.new("0835")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_830_to_835pm
    t1 = ZTime.new("0830")
    t2 = ZTime.new("0835", :pm)
    t1_after_modify = ZTime.new("0830", :pm)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_830pm_to_835
    t1 = ZTime.new("0830", :pm)
    t2 = ZTime.new("0835")
    t2_after_modify = ZTime.new("0835", :pm)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_835_to_835pm
    t1 = ZTime.new("0835")
    t2 = ZTime.new("0835", :pm)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_835am_to_835
    t1 = ZTime.new("0835", :am)
    t2 = ZTime.new("0835")
    t2_after_modify = ZTime.new("0835", :pm)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_835pm_to_835
    t1 = ZTime.new("0835", :pm)
    t2 = ZTime.new("0835")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_1021_to_1223am
    t1 = ZTime.new("1021")
    t2 = ZTime.new("1223", :am)
    t1_after_modify = ZTime.new("1021", :pm)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1021pm_to_1223
    t1 = ZTime.new("1021", :pm)
    t2 = ZTime.new("1223")
    t2_after_modify = ZTime.new("1223", :am)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_12_to_2am
    t1 = ZTime.new("12")
    t2 = ZTime.new("2", :am)
    t1_after_modify = ZTime.new("12", :am)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_12am_to_2
    t1 = ZTime.new("12", :am)
    t2 = ZTime.new("2")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_1220_to_2am
    t1 = ZTime.new("1220")
    t2 = ZTime.new("2", :am)
    t1_after_modify = ZTime.new("1220", :am)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1220am_to_2
    t1 = ZTime.new("1220", :am)
    t2 = ZTime.new("2")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_1220_to_12am
    t1 = ZTime.new("1220")
    t2 = ZTime.new("12", :am)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1220am_to_12
    t1 = ZTime.new("1220", :am)
    t2 = ZTime.new("12")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_1220_to_1220am
    t1 = ZTime.new("1220")
    t2 = ZTime.new("1220", :am)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1220pm_to_1220
    t1 = ZTime.new("1220", :pm)
    t2 = ZTime.new("1220")
    t2_after_modify = ZTime.new("1220", :am)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_930_to_5pm
    t1 = ZTime.new("0930")
    t2 = ZTime.new("5", :pm)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_930am_to_5
    t1 = ZTime.new("0930", :am)
    t2 = ZTime.new("5")
    t2_after_modify = ZTime.new("5", :pm)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_930_to_5am
    t1 = ZTime.new("0930")
    t2 = ZTime.new("5", :am)
    t1_after_modify = ZTime.new("0930", :pm)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_930pm_to_5
    t1 = ZTime.new("0930", :pm)
    t2 = ZTime.new("5")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_1100_to_425pm
    t1 = ZTime.new("1100")
    t2 = ZTime.new("0425", :pm)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1100am_to_425
    t1 = ZTime.new("1100", :am)
    t2 = ZTime.new("0425")
    t2_after_modify = ZTime.new("0425", :pm)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_1100_to_425am
    t1 = ZTime.new("1100")
    t2 = ZTime.new("0425", :am)
    t1_after_modify = ZTime.new("1100", :pm)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1100pm_to_425
    t1 = ZTime.new("1100", :pm)
    t2 = ZTime.new("0425")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_0115_to_0120am
    t1 = ZTime.new("0115")
    t2 = ZTime.new("0120", :am)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_0115am_to_0120
    t1 = ZTime.new("0115", :am)
    t2 = ZTime.new("0120")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_0115_to_0120pm
    t1 = ZTime.new("0115")
    t2 = ZTime.new("0120", :pm)
    t1_after_modify = ZTime.new("0115", :pm)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_0115pm_to_0120
    t1 = ZTime.new("0115", :pm)
    t2 = ZTime.new("0120")
    t2_after_modify = ZTime.new("0120", :pm)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_1020_to_1015am
    t1 = ZTime.new("1020")
    t2 = ZTime.new("1015", :am)
    t1_after_modify = ZTime.new("1020", :pm)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1020pm_to_1015
    t1 = ZTime.new("1020", :pm)
    t2 = ZTime.new("1015")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_1020_to_1015pm
    t1 = ZTime.new("1020")
    t2 = ZTime.new("1015", :pm)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1020am_to_1015
    t1 = ZTime.new("1020", :am)
    t2 = ZTime.new("1015")
    t2_after_modify = ZTime.new("1015", :pm)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end

  def test_1015_to_1020am
    t1 = ZTime.new("1015")
    t2 = ZTime.new("1020", :am)
    t1_after_modify = t1.dup
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1015pm_to_1020
    t1 = ZTime.new("1015", :pm)
    t2 = ZTime.new("1020")
    t2_after_modify = ZTime.new("1020", :pm)
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_1015_to_1020pm
    t1 = ZTime.new("1015")
    t2 = ZTime.new("1020", :pm)
    t1_after_modify = ZTime.new("1015", :pm)
    t1.modify_such_that_is_before(t2)
    assert_equal(t1_after_modify, t1)
  end

  def test_1015am_to_1020
    t1 = ZTime.new("1015", :am)
    t2 = ZTime.new("1020")
    t2_after_modify = t2.dup
    t2.modify_such_that_is_after(t1)
    assert_equal(t2_after_modify, t2)
  end
  
  def test_am_pm_modifier1
    t1 = ZTime.new("7", :pm)
    t1d = t1.dup
    ZTime.am_pm_modifier(t1)
    assert_equal(t1d, t1)
  end

  def test_am_pm_modifier2
    t1 = ZTime.new("7", :pm)
    t2 = ZTime.new("8")
    t1d = t1.dup
    ZTime.am_pm_modifier(t1,t2)
    assert_equal(t1d, t1)
    assert_equal(ZTime.new("8", :pm), t2)
  end
  
  def test_am_pm_modifier3
    t1 = ZTime.new("7")
    t2 = ZTime.new("8", :pm)
    t2d = t2.dup
    t3 = ZTime.new("9")

    ZTime.am_pm_modifier(t1,t2,t3)
    assert_equal(ZTime.new("7", :pm), t1)
    assert_equal(t2d, t2)
    assert_equal(ZTime.new("9", :pm), t3)    
  end

  def test_am_pm_modifier4
    t1 = ZTime.new("7")
    t2 = ZTime.new("8", :am)
    t3 = ZTime.new("9")
    t4 = ZTime.new("4", :pm)
    t5 = ZTime.new("7")
    
    ZTime.am_pm_modifier(t1,t2,t3,t4,t5)
    assert_equal(ZTime.new("7", :am), t1)
    assert_equal(ZTime.new("8", :am), t2)
    assert_equal(ZTime.new("9", :am), t3)
    assert_equal(ZTime.new("4", :pm), t4)
    assert_equal(ZTime.new("7", :pm), t5)    
  end
end

