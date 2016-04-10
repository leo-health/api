class AthenaSyncService
  def initialize
    @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
    @logger = Delayed::Worker.logger
  end
end
