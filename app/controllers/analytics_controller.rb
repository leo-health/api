class AnalyticsController < ApplicationController
  before_action :set_time_range, only: [:index]

  def index
    @analytics = AnalyticsService.new(@stats_time_range)

    respond_to do |format|
      format.html
      format.csv { send_data @analytics.to_csv,
                             filename: generate_csv_filename}
    end
  end


  protected  ## Protected methods until EOF

  # Reads a desired date range for the stats from provided params.
  # If date params are missing, assumes range from year 2015 to end of day today.
  def set_time_range
    begin_date = Date.strptime(params[:begin_date], '%Y-%m-%d') rescue Date.new(2015)
    end_date = Date.strptime(params[:end_date], '%Y-%m-%d') rescue Time.zone.today
    @stats_time_range = (begin_date.beginning_of_day)..(end_date.end_of_day)
  end

  def generate_csv_filename
    from = @stats_time_range.begin.strftime('%Y-%m-%d')
    to = @stats_time_range.end.strftime('%Y-%m-%d')
    "Leo Analytics #{from} - #{to}.csv"
  end
end
