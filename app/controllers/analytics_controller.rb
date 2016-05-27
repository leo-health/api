class AnalyticsController < ApplicationController
  before_action :set_time_range, only: [:index]

  def index
    @analytics = AnalyticsService.new(@stats_time_range)
  end


  protected  ## Protected methods until EOF

  # Reads a desired date range for the stats from provided params.
  # If date params are missing, assumes range from year 2015 to tomorrow.
  def set_time_range
    begin_date = Date.strptime(params[:begin_date], '%m-%d-%Y') rescue Date.new(2015)
    end_date = Date.strptime(params[:end_date], '%m-%d-%Y') rescue Date.tomorrow
    @stats_time_range = (begin_date.beginning_of_day)..(end_date.end_of_day)
  end
end
