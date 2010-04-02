require 'rubygems'
require 'mapricot'

module Nickel
  VERSION = "0.0.3"

  def self.query(q, current_time = Time.now)
    raise InvalidDateTimeError unless [DateTime, Time].include?(current_time.class)
    url = "http://naturalinputs.com/query?q=#{URI.escape(q)}&t=#{current_time.strftime("%Y%m%dT%H%M%S")}"
    Mapricot.parser = :libxml
    Api::NaturalInputsResponse.new(:url => url)
  end
end


module Nickel
  module Api
    class NaturalInputsResponse < Mapricot::Base
      has_one   :message
      has_many  :occurrences, :xml
    end

    class Occurrence < Mapricot::Base
      has_one   :type
      has_one   :start_date
      has_one   :end_date
      has_one   :start_time
      has_one   :end_time
      has_one   :day_of_week
      has_one   :week_of_month,   :integer
      has_one   :date_of_month,   :integer
      has_one   :interval,        :integer
    end
  end
end

class InvalidDateTimeError < StandardError
  def message
    "You must pass in a ruby DateTime or Time class object"
  end
end