# Run with: 
# ~/dev/nickel(master)$ rspec test/nickel_spec.rb
require File.expand_path(File.dirname(__FILE__) + "/../lib/nickel")


describe "A single date" do 
  before(:all) { @n = Nickel.parse "oct 15 09" }
  
  it "should have an empty message" do 
    @n.message.should be_empty
  end
  
  it "should have a start date" do 
    @n.occurrences.size.should == 1
    @n.occurrences.first.start_date.date.should == "20091015"
  end
end

describe "A daily occurrence" do 
  before(:all) do 
    @n = Nickel.parse "wake up everyday at 11am"
    @occurs = @n.occurrences.first
  end
  
  it "should have a message" do 
    @n.message.should == "wake up"
  end
  
  it "should be daily" do
    @occurs.type.should == :daily
  end
  
  it "should have a start time" do 
    @occurs.start_time.time.should == "110000"
  end
end


describe "A weekly occurrence" do
  before(:all) do 
    @n = Nickel.parse "guitar lessons every tuesday at 5pm"
    @occurs = @n.occurrences.first
  end
  
  it "should have a message" do
    @n.message.should == "guitar lessons"
  end
  
  it "should be weekly" do 
    @occurs.type.should == :weekly
  end
  
  
  it "should occur on tuesdays" do
    @occurs.day_of_week.should == 1
  end
  
  it "should occur once per week" do 
    @occurs.interval.should == 1
  end
  
  it "should start at 5pm" do 
    @occurs.start_time.time.should == "170000"
  end
  
  it "should have a start date" do 
    @occurs.start_date.should_not be_nil
  end
  
  it "should not have an end date" do 
    @occurs.end_date.should be_nil
  end
end


describe "A day monthly occurrence" do 
  before(:all) do 
    @n = Nickel.parse "drink specials on the second thursday of every month"
    @occurs = @n.occurrences.first
  end
  
  it "should have a message" do 
    @n.message.should == "drink specials"
  end
  
  it "should be day monthly" do 
    @occurs.type.should == :daymonthly
  end
  
  it "should occur on second thursday of every month" do 
    @occurs.week_of_month.should == 2
    @occurs.day_of_week.should == 3
  end
  
  it "should occur once per month" do 
    @occurs.interval.should == 1
  end
end



describe "A date monthly occurrence" do 
  before(:all) do 
    @n = Nickel.parse "pay credit card every month on the 22nd"
    @occurs = @n.occurrences.first
  end
  
  it "should have a message" do 
    @n.message.should == "pay credit card"
  end
  
  it "should be date monthly" do 
    @occurs.type.should == :datemonthly
  end
  
  it "should occur on the 22nd of every month" do
    @occurs.date_of_month.should == 22
  end
  
  it "should occur once per month" do 
    @occurs.interval.should == 1
  end
end


describe "Multiple occurrences" do 
  before(:all) do 
    @n = Nickel.parse "band meeting every monday and wednesday at 2pm"
  end
  
  it "should have a message" do 
    @n.message.should == "band meeting"
  end
  
  it "should have two occurrences" do 
    @n.occurrences.size.should == 2
  end
  
  it "should occur on mondays and wednesdays" do 
    days = @n.occurrences.collect {|occ| occ.day_of_week}
    days.include?(0).should be_true
    days.include?(2).should be_true
    days.size.should == 2
  end
  
  it "should occur at 2pm on both days" do 
    @n.occurrences[0].start_time.time.should == "140000"
    @n.occurrences[1].start_time.time.should == "140000"
  end
end

describe "Setting current time" do
  
  it "should occur on a date relative to the current time passed in" do
    n = Nickel.parse "lunch 3 days from now", DateTime.new(2009,05,28)
    n.occurrences.first.start_date.date.should == "20090531"
  end
  
  it "should raise an error if the current time argument is not a datetime or time object" do
    lambda{ 
      Nickel.parse "lunch 3 days from now", Date.new(2009,05,28) 
    }.should raise_error("You must pass in a ruby DateTime or Time class object")    
  end
end

