require 'rubygems'
require 'mapricot'

module Nickel
  VERSION = "0.0.1"

  def self.query(q)
    date_time = Time.now.strftime("%Y%m%dT%H%M%S")
    url = "http://www.naturalinputs.com/query?q=#{URI.escape(q)}&t=#{date_time}"
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